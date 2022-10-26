package service

import (
	"context"
	"errors"
	"gorm.io/gorm"
	"log"
	"ssssserver/pkg/session"
	"ssssserver/pkg/venom"
)

type FileService struct {
	venom.UnimplementedFileServiceServer
	dbConn      *gorm.DB
	sessionBook *session.SessionBook
}

func NewFileService(dbConn *gorm.DB, sessionBook *session.SessionBook) FileService {
	return FileService{
		dbConn:      dbConn,
		sessionBook: sessionBook,
	}
}

func (self *FileService) CreateFolder(_ context.Context, request *venom.CreateFolderRequest) (*venom.Void, error) {
	log.Printf("Received CreateFolder request")
	if request.Request.ParentId.Id == 0 {
		log.Printf("Invalid or missing folder id\n")
		return nil, errors.New("Invalid or missing parent folder id")
	}
	sess, err := self.sessionBook.Get(request.AuthToken)
	if err != nil {
		log.Printf("An error occurred fetching a session: %s\n", err)
		return nil, err
	}
	err = sess.CreateFolder(request.Request)
	if err != nil {
		log.Printf("An error occured during directory creation:  %s\n", err)
		return nil, errors.New("This folder already exists")
	}
	return &venom.Void{}, nil
}

func (self *FileService) CreateFile(_ context.Context, request *venom.CreateFileRequest) (*venom.FileId, error) {
	log.Printf("Received CreateFile request")
	if request.Request.ParentId.Id == 0 {
		log.Printf("Invalid or missing folder id\n")
		return nil, errors.New("Invalid or missing parent folder id")
	}
	sess, err := self.sessionBook.Get(request.AuthToken)
	if err != nil {
		log.Printf("An error occurred fetching a session: %s\n", err)
		return nil, err
	}
	fileId, err := sess.CreateFileMetadata(request.Request)
	if err != nil {
		log.Printf("An error occured during directory creation:  %s\n", err)
		return nil, errors.New("This folder already exists")
	}
	return fileId, nil
}

func (self *FileService) GetRootFolder(_ context.Context, request *venom.AuthToken) (*venom.FileMetadata, error) {
	sess, err := self.sessionBook.Get(request)
	if err != nil {
		log.Printf("An error occurred fetching a session: %s\n", err)
		return nil, err
	}
	folder, err := sess.GetRootFolder()
	if err != nil {
		log.Printf("Failed to get root folder: %s\n", err)
		return nil, errors.New("An unknown error occurred")
	}
	return folder, nil
}

func (self *FileService) GetFolderContents(request *venom.GetContentsRequest, stream venom.FileService_GetFolderContentsServer) error {
	log.Printf("Began a GetFolderContents stream")

	if request.Request.FolderId.Id == 0 {
		log.Printf("Invalid or missing folder id\n")
		return errors.New("Invalid or missing folder id")
	}
	sess, err := self.sessionBook.Get(request.AuthToken)
	if err != nil {
		log.Printf("An error occurred fetching a session: %s\n", err)
		return errors.New("An unknown error occurred")
	}

	recv, err := sess.FolderContentsListener(request.Request.FolderId.Id)
	if err != nil {
		log.Printf("An error occurred getting folder contents: %s\n", err)
		return errors.New("An unknown error occurred")
	}

	keepStreaming := true
	for keepStreaming {
		select {
		case contents, more := <-recv:
			if !more {
				keepStreaming = false
				break
			}
			err := stream.Send(contents)
			if err != nil {
				log.Printf("An error occurred sending to stream %s\n", err)
				keepStreaming = false
			}
		case <-stream.Context().Done():
			keepStreaming = false
		}
	}
	sess.StopFolderContentsListener(request.Request.FolderId.Id, recv)
	log.Printf("Terminated a GetFolderContents stream")
	return nil
}
