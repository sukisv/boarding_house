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
