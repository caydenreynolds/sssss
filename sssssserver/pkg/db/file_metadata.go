package db

import (
	"gorm.io/gorm"
)

type FileMetadata struct {
	ID             uint64
	Name           string `gorm:"uniqueIndex:nodupe"`
	OwnerId        uint64
	Owner          User
	ParentFolderId uint64 `gorm:"uniqueIndex:nodupe"`
	ParentFolder   Folder
}

func FindFileMetadata(conn *gorm.DB, owner User, id uint64) (FileMetadata, error) {
	query := FileMetadata{
		ID:      id,
		OwnerId: owner.ID,
	}
	var target FileMetadata
	result := conn.Where(&query).Take(&target)
	return target, result.Error
}

func CreateFileMetadata(conn *gorm.DB, owner User, parentId uint64, name string) (FileMetadata, error) {
	newMetadata := FileMetadata {
		ParentFolderId: parentId,
		Name:           name,
		Owner:          owner,
	}
	return newMetadata, conn.Transaction(func(tx *gorm.DB) error {
		_, err := FindFolder(tx, parentId)
		if err != nil {
			return err
		}
		tx.Create(&newMetadata)
		return nil
	})
}
