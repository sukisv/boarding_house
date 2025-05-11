package config

import (
	"anak_kos/models"
	"fmt"
	"log"
	"os"
	"time"

	"gorm.io/driver/mysql"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
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

	database, err := gorm.Open(mysql.Open(dsn), &gorm.Config{
		Logger: logger.New(
			log.New(os.Stdout, "\r\n", log.LstdFlags),
			logger.Config{
				SlowThreshold:             time.Second, // Log queries slower than this threshold
				LogLevel:                  logger.Info, // Log all queries
				IgnoreRecordNotFoundError: true,
				Colorful:                  true,
			},
		),
	})
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
