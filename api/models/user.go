package models

import (
	"time"

	"github.com/google/uuid"
	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"
)

type UserRole string

const (
	RoleSeeker UserRole = "seeker"
	RoleOwner  UserRole = "owner"
)

type User struct {
	ID          uuid.UUID `gorm:"type:char(36);primaryKey" json:"id"`
	Name        string    `gorm:"type:varchar(255);not null" json:"name"`
	Email       string    `gorm:"type:varchar(255);not null;unique" json:"email"`
	Password    string    `gorm:"type:varchar(255);not null" json:"password"`
	Role        UserRole  `gorm:"type:enum('seeker', 'owner');not null" json:"role"`
	PhoneNumber string    `gorm:"type:varchar(20);default:null" json:"phone_number"`

	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `gorm:"index" json:"-"`
}

func (item *User) BeforeCreate(tx *gorm.DB) (err error) {
	if item.ID == uuid.Nil {
		item.ID = uuid.New()
	}

	if item.Password != "" {
		hashedPassword, err := bcrypt.GenerateFromPassword([]byte(item.Password), bcrypt.DefaultCost)
		if err != nil {
			return err
		}
		item.Password = string(hashedPassword)
	}

	return
}

func (item *User) BeforeUpdate(tx *gorm.DB) (err error) {
	if item.Password != "" {
		hashedPassword, err := bcrypt.GenerateFromPassword([]byte(item.Password), bcrypt.DefaultCost)
		if err != nil {
			return err
		}
		item.Password = string(hashedPassword)
	}

	return
}

// UserRequest represents the request payload for creating or updating a User
type UserRequest struct {
	Name        string `json:"name" binding:"required"`
	PhoneNumber string `json:"phone_number" binding:"omitempty"`
}

// UserResponse represents the response payload for a User
type UserResponse struct {
	ID          string    `json:"id"`
	Name        string    `json:"name"`
	Email       string    `json:"email"`
	Role        string    `json:"role"`
	PhoneNumber string    `json:"phone_number"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
}

// RegisterRequest represents the request payload for user registration
type RegisterRequest struct {
	Name        string `json:"name" binding:"required"`
	Email       string `json:"email" binding:"required,email"`
	Password    string `json:"password" binding:"required,min=8"`
	Role        string `json:"role" binding:"required,oneof=seeker owner"`
	PhoneNumber string `json:"phone_number" binding:"omitempty"`
}

// RegisterResponse represents the response payload after registration
type RegisterResponse struct {
	ID          string    `json:"id"`
	Name        string    `json:"name"`
	Email       string    `json:"email"`
	Role        string    `json:"role"`
	PhoneNumber string    `json:"phone_number"`
	CreatedAt   time.Time `json:"created_at"`
}

// LoginRequest represents the request payload for user login
type LoginRequest struct {
	Email    string `json:"email" binding:"required,email"`
	Password string `json:"password" binding:"required"`
}

// LoginResponse represents the response payload after login
type LoginResponse struct {
	Token string       `json:"token"`
	User  UserResponse `json:"user"`
}
