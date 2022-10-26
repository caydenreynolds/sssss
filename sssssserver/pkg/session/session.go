package session

import (
	"log"
	"ssssserver/pkg/db"
	"ssssserver/pkg/generic"
	"ssssserver/pkg/venom"
	"strconv"
	"time"

	"gorm.io/gorm"
)

var sessionTimeoutTime = 4 * time.Hour

type Session struct {
	dbConn          *gorm.DB
	user            db.User
	contentsSenders generic.LockedSet[contentsListener]
	contentsUpdate  chan uint64
}

func newSession(dbConn *gorm.DB, user db.User) *Session {
	sess := Session{
		dbConn:          dbConn,
		user:            user,
		contentsSenders: generic.NewLockedSet[contentsListener](),
		contentsUpdate:  make(chan uint64, 1),
	}
	go sess.folderContentsNotifier()
	return &sess
}

// CreateFolder creates a new folder and notifies all listeners
func (self *Session) CreateFolder(folder *venom.CreateFolder) error {
	parentId := folder.ParentId.GetId()
	err := db.CreateFolder(self.dbConn, self.user, folder.Name, &parentId)
	if err == nil {
		self.contentsUpdate <- parentId
	}
	return err
}

// CreateFolder creates a new file and notifies all listeners
func (self *Session) CreateFileMetadata(metadata *venom.CreateFile) (*venom.FileId, error) {
	parentId := metadata.ParentId.GetId()
	fileMetadata, err := db.CreateFileMetadata(self.dbConn, self.user, parentId, metadata.Name)
	if err == nil {
	}
	return &venom.FileId{Id: fileMetadata.ID}, err
}

func (self *Session) close() {
	close(self.contentsUpdate)
	self.contentsSenders.ForEach(func(element contentsListener) {
		close(element.sendChan)
	})
}

// GetRootFolder returns the root folder for this Session's user
func (self *Session) GetRootFolder() (*venom.FileMetadata, error) {
	folder, err := db.GetRootFolder(self.dbConn, self.user)
	if err != nil {
		return nil, err
	}
	return &venom.FileMetadata{
		Id:   &venom.FileId{Id: folder.ID},
		Name: folder.Name,
		Type: venom.FileType_FOLDER,
	}, nil
}

func (self *Session) FolderContentsListener(folderId uint64) (chan *venom.FolderContents, error) {
	contentsChannel := make(chan *venom.FolderContents, 1)
	listener := contentsListener{
		listenFolder: folderId,
		sendChan:     contentsChannel,
	}
	self.contentsSenders.Insert(listener)
	contents, err := self.getFolderContents(folderId)
	if err != nil {
		return contentsChannel, err
	}
	contentsChannel <- &contents
	return contentsChannel, nil
}

func (self *Session) StopFolderContentsListener(folderId uint64, channel chan *venom.FolderContents) {
	listener := contentsListener{
		listenFolder: folderId,
		sendChan:     channel,
	}
	self.contentsSenders.Remove(listener)
	close(channel)
}

func (self *Session) VerifyNewFileId(fileId string) bool {
	fileIdInt, err := strconv.ParseUint(fileId, 10, 64)
	if err != nil {
		return false
	}
	_, err = db.FindFileMetadata(self.dbConn, self.user, fileIdInt)
	return err == nil
}

func (self *Session) folderContentsNotifier() {
	for folderId := range self.contentsUpdate {
		contents, err := self.getFolderContents(folderId)
		if err != nil {
			log.Printf("An error occurred getting folder contents: %s\n", err)
			continue
		}
		self.contentsSenders.ForEach(func(listener contentsListener) {
			if listener.listenFolder == folderId {
				listener.sendChan <- &contents
			}
		})
	}
}

func (self *Session) getFolderContents(folderId uint64) (venom.FolderContents, error) {
	folders, err := db.GetFolderContents(self.dbConn, folderId)
	if err != nil {
		return venom.FolderContents{}, err
	}
	// TODO: Get files
	fms := make([]*venom.FileMetadata, len(folders))
	for i, folder := range folders {
		fms[i] = &venom.FileMetadata{
			Id:   &venom.FileId{Id: folder.ID},
			Name: folder.Name,
			Type: venom.FileType_FOLDER,
		}
	}
	return venom.FolderContents{
		Contents: fms,
	}, nil
}

type contentsListener struct {
	listenFolder uint64
	sendChan     chan *venom.FolderContents
}
