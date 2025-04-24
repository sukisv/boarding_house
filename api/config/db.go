package config

import (
	"anak_kos/models"
	"fmt"
	"os"

	"gorm.io/driver/mysql"
	"gorm.io/gorm"
)

var DB *gorm.DB

func SetupDatabase() {
	dsn := fmt.Sprintf(
		"%s:%s@tcp(%s:%s)/%s?charset=utf8mb4&parseTime=True&loc=Local",
		os.Getenv("DB_USER"),
		os.Getenv("DB_PASSWORD"),
		os.Getenv("DB_HOST"),
		os.Getenv("DB_PORT"),
		os.Getenv("DB_NAME"),
	)

	database, err := gorm.Open(mysql.Open(dsn), &gorm.Config{})
	if err != nil {
		panic("Gagal koneksi ke database: " + err.Error())
	}

	err = database.AutoMigrate(
		&models.User{},
		&models.BoardingHouse{},
		&models.Facility{},
		&models.BoardingHouseFacility{},
		&models.Favorite{},
		&models.Booking{},
		&models.BoardingHouseImage{},
	)

	if err != nil {
		panic("Gagal migrasi: " + err.Error())
	}

	DB = database
}
