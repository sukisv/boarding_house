package models

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type BoardingHouse struct {
	ID            uuid.UUID `gorm:"type:char(36);primaryKey" json:"id"`
	OwnerID       uuid.UUID `gorm:"type:char(36);not null" json:"owner_id"`
	Name          string    `gorm:"type:varchar(255);not null" json:"name"`
	Description   string    `gorm:"type:text" json:"description"`
	Address       string    `gorm:"type:text" json:"address"`
	City          string    `gorm:"type:varchar(100)" json:"city"`
	PricePerMonth float64   `gorm:"type:decimal(10,2)" json:"price_per_month"`
	RoomAvailable int       `gorm:"default:0" json:"room_available"`
	GenderAllowed string    `gorm:"type:enum('male','female','mixed')" json:"gender_allowed"`

	Owner      User                 `gorm:"foreignKey:OwnerID" json:"owner"`
	Facilities []Facility           `gorm:"many2many:boarding_house_facilities;" json:"facilities"`
	Images     []BoardingHouseImage `gorm:"foreignKey:BoardingHouseID" json:"images"`

	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `gorm:"index" json:"-"`
}

func (item *BoardingHouse) BeforeCreate(tx *gorm.DB) (err error) {
	if item.ID == uuid.Nil {
		item.ID = uuid.New()
	}
	return
}

// BoardingHouseRequest represents the request payload for creating or updating a BoardingHouse
type BoardingHouseRequest struct {
	OwnerID       string  `json:"owner_id" binding:"required,uuid"`
	Name          string  `json:"name" binding:"required"`
	Description   string  `json:"description"`
	Address       string  `json:"address" binding:"required"`
	City          string  `json:"city" binding:"required"`
	PricePerMonth float64 `json:"price_per_month" binding:"required,gt=0"`
	RoomAvailable int     `json:"room_available" binding:"required,gte=0"`
	GenderAllowed string  `json:"gender_allowed" binding:"required,oneof=male female mixed"`
}

// BoardingHouseResponse represents the response payload for a BoardingHouse
type BoardingHouseResponse struct {
	ID            string                       `json:"id"`
	OwnerID       string                       `json:"owner_id"`
	Name          string                       `json:"name"`
	Description   string                       `json:"description"`
	Address       string                       `json:"address"`
	City          string                       `json:"city"`
	PricePerMonth float64                      `json:"price_per_month"`
	RoomAvailable int                          `json:"room_available"`
	GenderAllowed string                       `json:"gender_allowed"`
	Facilities    []FacilityResponse           `json:"facilities"`
	Images        []BoardingHouseImageResponse `json:"images"`
	CreatedAt     time.Time                    `json:"created_at"`
	UpdatedAt     time.Time                    `json:"updated_at"`
}
