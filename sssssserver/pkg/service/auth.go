package service

import (
	"context"
	"errors"
	"fmt"
	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"
	"log"
	"ssssserver/pkg/db"
	"ssssserver/pkg/generic"
	"ssssserver/pkg/session"
	"ssssserver/pkg/venom"
	"strings"
)

type AuthService struct {
	venom.UnimplementedAuthServiceServer
	dbConn      *gorm.DB
	sessionBook *session.SessionBook
}

func NewAuthService(dbConn *gorm.DB, sessionBook *session.SessionBook) AuthService {
	return AuthService{
		dbConn:      dbConn,
		sessionBook: sessionBook,
	}
}

func (self *AuthService) Login(_ context.Context, credentials *venom.Credentials) (*venom.AuthToken, error) {
	log.Print("Received Login request")
	user, err := db.FindUser(self.dbConn, credentials.Username)
	if err != nil {
		return nil, errors.New("Incorrect username or password")
	}
	// Else
	err = bcrypt.CompareHashAndPassword([]byte(user.Password), credentials.Password)
	if err != nil {
		return nil, errors.New("Incorrect username or password")
	}

	authToken, err := generic.NewAuthToken()
	if err != nil {
		log.Printf("An error occured during user login:  %s\n", err)
		return nil, errors.New("An unknown error occurred")
	}
	self.sessionBook.Register(user, authToken)
	return authToken, nil
}

func (self *AuthService) NewUser(_ context.Context, credentials *venom.Credentials) (*venom.AuthToken, error) {
	log.Print("Received NewUser request")
	pwdHash, err := bcrypt.GenerateFromPassword(credentials.Password, pwdCost)
	if err != nil {
		return nil, err
	}

	var userResult db.User
	err = self.dbConn.Transaction(func(tx *gorm.DB) error {
		user, err := db.CreateUser(tx, credentials.Username, string(pwdHash))
		userResult = user
		if err != nil {
			log.Printf("An error occured while inserting a new user into the database:  %s\n", err)
			err_str := fmt.Sprint(err)
			if strings.Contains(err_str, "unique") {
				return errors.New("User already exists")
			}
			return errors.New("An unknown error occurred")
		}
		// Create a root folder for the new user
		err = db.CreateFolder(tx, user, "root", nil)
		if err != nil {
			log.Printf("An error occurred creating this user's root folder: %s\n", err)
			return errors.New("An unknown error occurred")
		}
		return nil
	})
	if err != nil {
		return nil, err
	}

	authToken, err := generic.NewAuthToken()
	if err != nil {
		log.Printf("An error occured while generating an auth token:  %s\n", err)
		return nil, errors.New("An unknown error occurred")
	}
	self.sessionBook.Register(userResult, authToken)
	return authToken, nil
}
