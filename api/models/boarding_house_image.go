package models

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type BoardingHouseImage struct {
	ID uuid.UUID `gorm:"type:char(36);primaryKey" json:"id"`

	BoardingHouseID uuid.UUID `gorm:"type:uuid;not null" json:"boarding_house_id"`
	ImageURL        string    `gorm:"not null" json:"image_url"`

	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `gorm:"index" json:"-"`

	BoardingHouse BoardingHouse `gorm:"foreignKey:BoardingHouseID"`
}

func (item *BoardingHouseImage) BeforeCreate(tx *gorm.DB) (err error) {
	if item.ID == uuid.Nil {
		item.ID = uuid.New()
	}
	return
}
