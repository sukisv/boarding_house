package controllers

import (
	"anak_kos/config"
	"anak_kos/context"
	"anak_kos/models"
	"encoding/base64"
	"encoding/json"
	"net/http"
	"time"

	"github.com/google/uuid"
	"github.com/labstack/echo/v4"
	"golang.org/x/crypto/bcrypt"
)

func Login(c echo.Context) error {
	var credentials models.User
	if err := c.Bind(&credentials); err != nil {
		return c.JSON(http.StatusBadRequest, echo.Map{"error": "Invalid request payload"})
	}

	var user models.User
	if err := config.DB.Where("email = ?", credentials.Email).First(&user).Error; err != nil {
		return c.JSON(http.StatusUnauthorized, echo.Map{"error": "Invalid email or password"})
	}

	if err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(credentials.Password)); err != nil {
		return c.JSON(http.StatusUnauthorized, echo.Map{"error": "Invalid email or password"})
	}

	sessionID := uuid.New().String()

	userInfo := context.AuthenticatedUser{
		ID:          user.ID,
		Name:        user.Name,
		Email:       user.Email,
		Role:        string(user.Role),
		PhoneNumber: user.PhoneNumber,
	}

	userInfoJSON, err := json.Marshal(userInfo)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{"error": "Failed to serialize user info"})
	}

	encodedUserInfo := base64.StdEncoding.EncodeToString(userInfoJSON)

	c.SetCookie(&http.Cookie{
		Name:     "session_id",
		Value:    sessionID,
		Path:     "/",
		HttpOnly: true,
		Secure:   false,
		Expires:  time.Now().Add(30 * 24 * time.Hour),
	})

	c.SetCookie(&http.Cookie{
		Name:     "user_info",
		Value:    encodedUserInfo,
		Path:     "/",
		HttpOnly: true,
		Secure:   false,
		Expires:  time.Now().Add(30 * 24 * time.Hour),
	})

	return c.JSON(http.StatusOK, echo.Map{
		"message": "Login successful",
		"status":  "success",
	})
}

func Register(c echo.Context) error {
	var user models.User

	if err := c.Bind(&user); err != nil {
		return c.JSON(http.StatusBadRequest, echo.Map{"error": "Invalid request body"})
	}

	var existingUser models.User
	if err := config.DB.Where("email = ?", user.Email).First(&existingUser).Error; err == nil {
		return c.JSON(http.StatusConflict, echo.Map{"error": "User already exists"})
	}

	if err := config.DB.Create(&user).Error; err != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{"error": "Failed to register user"})
	}

	return c.JSON(http.StatusOK, echo.Map{
		"message": "Registration successful",
		"user":    user,
	})
}

func Logout(c echo.Context) error {
	c.SetCookie(&http.Cookie{
		Name:     "session_id",
		Value:    "",
		Path:     "/",
		HttpOnly: true,
		Secure:   false,
		MaxAge:   -1,
	})

	c.SetCookie(&http.Cookie{
		Name:     "user_info",
		Value:    "",
		Path:     "/",
		HttpOnly: true,
		Secure:   false,
		MaxAge:   -1,
	})

	return c.JSON(http.StatusOK, echo.Map{
		"message": "Logout successful",
		"status":  "success",
	})
}
