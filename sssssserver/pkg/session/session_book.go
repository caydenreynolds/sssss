package session

import (
	"errors"
	"gorm.io/gorm"
	"ssssserver/pkg/db"
	"ssssserver/pkg/venom"
	"sync"
	"time"
)

// SessionBook is a thread-safe mapping of AuthTokens to Sessions
// RPCs can use SessionBook to ensure requests are handled by the correct session
// The idea is that any given user maintains exactly one session at a time
// Any number of tokens can refer to a given Session
type SessionBook struct {
	dbConn        *gorm.DB
	sessions      map[comparableAuthToken]sessionRecord
	sessionNames  map[string]sessionRecord
	sessionTimers map[string]chan struct{}
	mutex         sync.RWMutex
}

type sessionRecord struct {
	session      *Session
	resetTimeout chan struct{}
}

func NewSessionBook(dbConn *gorm.DB) SessionBook {
	return SessionBook{
		dbConn:       dbConn,
		sessions:     make(map[comparableAuthToken]sessionRecord),
		sessionNames: make(map[string]sessionRecord),
		mutex:        sync.RWMutex{},
	}
}

// Get returns a pointer to the Session referenced by the given AuthToken
// If the session has been closed, returns nil
func (self *SessionBook) Get(token *venom.AuthToken) (*Session, error) {
	compToken := authTokenToComparable(token)
	self.mutex.RLock()
	defer self.mutex.RUnlock()
	record, ok := self.sessions[compToken]
	if ok {
		record.resetTimeout <- struct{}{}
		return record.session, nil
	} else {
		return nil, errors.New("Authentication failed")
	}
}

// Register a session for the given user, with the given AuthToken
// If a session already exists for this user, the new token will be registered, pointing to the existing session
// If no session already exists for this user, a new Session will be created
func (self *SessionBook) Register(user db.User, token *venom.AuthToken) {
	compToken := authTokenToComparable(token)
	self.mutex.Lock()
	defer self.mutex.Unlock()
	record, ok := self.sessionNames[user.Username]
	if ok {
		// Map new token to old session
		self.sessions[compToken] = record
	} else {
		// Init new session
		sess := newSession(self.dbConn, user)
		resetTimeout := make(chan struct{})
		newRecord := sessionRecord{
			session:      sess,
			resetTimeout: resetTimeout,
		}
		self.sessionNames[user.Username] = newRecord
		self.sessions[compToken] = newRecord
		go self.sessionTimeout(sess, resetTimeout)
	}
}

// Unregister all tokens pointing to a user's session, and remove all references to that session
func (self *SessionBook) unregister(user db.User) {
	self.mutex.Lock()
	defer self.mutex.Unlock()
	record, ok := self.sessionNames[user.Username]
	if ok {
		delete(self.sessionNames, user.Username)
		for key, value := range self.sessions {
			if value == record {
				delete(self.sessions, key)
			}
		}
		close(record.resetTimeout)
	}
}

type comparableAuthToken struct {
	mostSignificant  uint64
	leastSignificant uint64
}

func authTokenToComparable(token *venom.AuthToken) comparableAuthToken {
	return comparableAuthToken{
		mostSignificant:  token.MostSignificant,
		leastSignificant: token.LeastSignificant,
	}
}

func (self *SessionBook) sessionTimeout(session *Session, recv chan struct{}) {
	timer := time.NewTimer(sessionTimeoutTime)
	for {
		select {
		case _, more := <-recv:
			if !more {
				return
			}
			// Reset the timeout
			if !timer.Stop() {
				<-timer.C
			}
			timer.Reset(sessionTimeoutTime)
		case <-timer.C:
			// Close the session
			self.unregister(session.user)
			session.close()
		}
	}
}
