package db

import (
	"gorm.io/gorm"
)

type User struct {
	ID       uint64
	Username string `gorm:"uniqueIndex"`
	Password string
}

func FindUser(conn *gorm.DB, username string) (User, error) {
	query := User{
		Username: username,
	}
	var target User
	result := conn.Where(&query).Take(&target)
	if result.Error != nil {
		return User{}, result.Error
	}
	return target, nil
}

func CreateUser(conn *gorm.DB, username string, password string) (User, error) {
	usr := User{
		Username: username,
		Password: password,
	}
	result := conn.Create(&usr)
	return usr, result.Error
}
