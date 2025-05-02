package models

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type Favorite struct {
	ID              uuid.UUID      `gorm:"type:char(36);primaryKey" json:"id"`
	UserID          uuid.UUID      `gorm:"type:char(36);not null" json:"user_id"`
	BoardingHouseID uuid.UUID      `gorm:"type:char(36);not null" json:"boarding_house_id"`
	CreatedAt       time.Time      `json:"created_at"`
	UpdatedAt       time.Time      `json:"updated_at"`
	DeletedAt       gorm.DeletedAt `gorm:"index" json:"-"`

	User          User          `gorm:"foreignKey:UserID" json:"user"`
	BoardingHouse BoardingHouse `gorm:"foreignKey:BoardingHouseID" json:"boarding_house"`
}

func (f *Favorite) BeforeCreate(tx *gorm.DB) (err error) {
	if f.ID == uuid.Nil {
		f.ID = uuid.New()
	}
	return
}

// FavoriteRequest represents the request payload for creating or updating a Favorite
type FavoriteRequest struct {
	UserID          string `json:"user_id" binding:"required,uuid"`
	BoardingHouseID string `json:"boarding_house_id" binding:"required,uuid"`
}

// FavoriteResponse represents the response payload for a Favorite
type FavoriteResponse struct {
	ID              string                 `json:"id"`
	UserID          string                 `json:"user_id"`
	BoardingHouseID string                 `json:"boarding_house_id"`
	User            *UserResponse          `json:"user,omitempty"`
	BoardingHouse   *BoardingHouseResponse `json:"boarding_house,omitempty"`
	CreatedAt       time.Time              `json:"created_at"`
	UpdatedAt       time.Time              `json:"updated_at"`
}
