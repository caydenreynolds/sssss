package db

import (
	"fmt"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	"net/url"
)

func Connect(username string, password string) (*gorm.DB, error) {
	// TODO: Enable ssl
	dsn := fmt.Sprintf("host=perry user=%s password=%s dbname=%s", username, url.QueryEscape(password), dbName)
	db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{})
	if err != nil {
		return nil, err
	}
	err = db.AutoMigrate(&User{}, &Folder{}, &FileMetadata{})
	if err != nil {
		return nil, err
	}
	return db, nil
}
