package db

import "gorm.io/gorm"

type Folder struct {
	ID             uint64
	Name           string `gorm:"uniqueIndex:nodupe"`
	OwnerId        uint64
	Owner          User
	ParentFolderId *uint64  `gorm:"uniqueIndex:nodupe"`
	ChildFolders   []Folder `gorm:"foreignkey:ParentFolderId"`
	// ChildFiles     []FileMetadata
}

func CreateFolder(conn *gorm.DB, owner User, name string, parentId *uint64) error {
	return conn.Transaction(func(tx *gorm.DB) error {
		if parentId != nil {
			_, err := FindFolder(tx, *parentId)
			if err != nil {
				return err
			}
		}
		newFolder := Folder{
			ParentFolderId: parentId,
			Name:           name,
			Owner:          owner,
		}
		tx.Create(&newFolder)
		return nil
	})
}

func FindFolder(conn *gorm.DB, id uint64) (Folder, error) {
	query := Folder{
		ID: id,
	}
	var target Folder
	result := conn.Where(&query).Take(&target)
	return target, result.Error
}

func GetRootFolder(conn *gorm.DB, owner User) (Folder, error) {
	query := Folder{
		OwnerId:        owner.ID,
		ParentFolderId: nil,
	}
	var target Folder
	result := conn.Where(&query).Take(&target)
	return target, result.Error
}

func GetFolderContents(conn *gorm.DB, parentId uint64) ([]Folder, error) {
	query := Folder{
		ParentFolderId: &parentId,
	}
	var folders []Folder
	result := conn.Where(&query).Find(&folders)
	return folders, result.Error
}
