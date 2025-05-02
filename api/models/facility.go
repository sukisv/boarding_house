package models

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type Facility struct {
	ID        uuid.UUID      `gorm:"type:char(36);primaryKey" json:"id"`
	Name      string         `gorm:"type:varchar(255);not null" json:"name"`
	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `gorm:"index" json:"-"`

	BoardingHouses []BoardingHouse `gorm:"many2many:boarding_house_facilities;" json:"boarding_houses"`
}

func (item *Facility) BeforeCreate(tx *gorm.DB) (err error) {
	if item.ID == uuid.Nil {
		item.ID = uuid.New()
	}
	return
}

// FacilityRequest represents the request payload for creating or updating a Facility
type FacilityRequest struct {
	Name string `json:"name" binding:"required"`
}

// FacilityResponse represents the response payload for a Facility
type FacilityResponse struct {
	ID   string `json:"id"`
	Name string `json:"name"`
}
