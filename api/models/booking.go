package models

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type BookingStatus string

const (
	BookingPending   BookingStatus = "pending"
	BookingConfirmed BookingStatus = "confirmed"
	BookingCancelled BookingStatus = "cancelled"
)

type Booking struct {
	ID              uuid.UUID     `gorm:"type:char(36);primaryKey" json:"id"`
	UserID          uuid.UUID     `gorm:"type:char(36);not null" json:"user_id"`
	BoardingHouseID uuid.UUID     `gorm:"type:char(36);not null" json:"boarding_house_id"`
	StartDate       time.Time     `gorm:"type:date;not null" json:"start_date"`
	EndDate         time.Time     `gorm:"type:date;not null" json:"end_date"`
	Status          BookingStatus `gorm:"type:enum('pending','confirmed','cancelled');default:'pending'" json:"status"`

	User          *User          `gorm:"foreignKey:UserID" json:"user,omitempty"`
	BoardingHouse *BoardingHouse `gorm:"foreignKey:BoardingHouseID" json:"boarding_house,omitempty"`

	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `gorm:"index" json:"-"`
}

// Auto generate UUID before creation
func (b *Booking) BeforeCreate(tx *gorm.DB) (err error) {
	if b.ID == uuid.Nil {
		b.ID = uuid.New()
	}
	return
}

// BookingRequest represents the request payload for creating or updating a Booking
// Pastikan StartDate dan EndDate bertipe string agar bisa di-parse dari JSON
// Contoh: "start_date": "2024-07-01", "end_date": "2024-07-31"
type BookingRequest struct {
	BoardingHouseID string `json:"boarding_house_id" binding:"required"`
	StartDate       string `json:"start_date" binding:"required"`
	EndDate         string `json:"end_date" binding:"required"`
}

// BookingResponse represents the response payload for a Booking
type BookingResponse struct {
	ID              string        `json:"id"`
	UserID          string        `json:"user_id"`
	BoardingHouseID string        `json:"boarding_house_id"`
	StartDate       time.Time     `json:"start_date"`
	EndDate         time.Time     `json:"end_date"`
	Status          BookingStatus `json:"status"`
	CreatedAt       time.Time     `json:"created_at"`
	UpdatedAt       time.Time     `json:"updated_at"`

	User          *UserResponse          `json:"user,omitempty"`
	BoardingHouse *BoardingHouseResponse `json:"boarding_house,omitempty"`
}
