package controllers

import (
	"anak_kos/config"
	"anak_kos/models"
	"encoding/base64"
	"encoding/json"
	"net/http"
	"time"

	"github.com/google/uuid"
	"github.com/jinzhu/copier"
	"github.com/labstack/echo/v4"
	"golang.org/x/crypto/bcrypt"
)

func Login(c echo.Context) error {
	// Bind request payload
	var loginRequest models.UserRequest
	if err := c.Bind(&loginRequest); err != nil {
		return c.JSON(http.StatusBadRequest, echo.Map{
			"message": "Invalid request payload",
			"status":  "error",
			"data":    err.Error(),
		})
	}

	// Find user by email
	var user models.User
	if err := config.DB.Where("email = ?", loginRequest.Email).First(&user).Error; err != nil {
		return c.JSON(http.StatusUnauthorized, echo.Map{
			"message": "Invalid email or password",
			"status":  "error",
		})
	}

	// Compare password
	if err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(loginRequest.Password)); err != nil {
		return c.JSON(http.StatusUnauthorized, echo.Map{
			"message": "Invalid email or password",
			"status":  "error",
		})
	}

	// Generate session ID
	sessionID := uuid.New().String()

	// Copy user data to response struct
	userInfo := models.UserResponse{}
	if err := copier.Copy(&userInfo, &user); err != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{
			"message": "Failed to process user data",
			"status":  "error",
		})
	}

	// Serialize user info
	userInfoJSON, err := json.Marshal(userInfo)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{
			"message": "Failed to serialize user info",
			"status":  "error",
		})
	}

	// Encode user info to base64
	encodedUserInfo := base64.StdEncoding.EncodeToString(userInfoJSON)

	// Set cookies
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

	// Return response
	return c.JSON(http.StatusOK, echo.Map{
		"message": "Login successful",
		"status":  "success",
		"user":    userInfo,
	})
}

func Register(c echo.Context) error {
	// Bind request payload
	var registerRequest models.UserRequest
	if err := c.Bind(&registerRequest); err != nil {
		return c.JSON(http.StatusBadRequest, echo.Map{
			"message": "Invalid request body",
			"status":  "error",
			"data":    err.Error(),
		})
	}

	// Check if user already exists
	var existingUser models.User
	if err := config.DB.Where("email = ?", registerRequest.Email).First(&existingUser).Error; err == nil {
		return c.JSON(http.StatusConflict, echo.Map{
			"message": "User already exists",
			"status":  "error",
		})
	}

	// Copy request data to user model
	user := models.User{}
	if err := copier.Copy(&user, &registerRequest); err != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{
			"message": "Failed to process registration data",
			"status":  "error",
		})
	}

	// Save user to database
	if err := config.DB.Create(&user).Error; err != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{
			"message": "Failed to register user",
			"status":  "error",
		})
	}

	// Copy user data to response struct
	registerResponse := models.UserResponse{}
	if err := copier.Copy(&registerResponse, &user); err != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{
			"message": "Failed to process response data",
			"status":  "error",
		})
	}

	// Return response
	return c.JSON(http.StatusOK, echo.Map{
		"message": "Registration successful",
		"status":  "success",
		"user":    registerResponse,
	})
}

func Logout(c echo.Context) error {
	// Clear cookies
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

	// Return response
	return c.JSON(http.StatusOK, echo.Map{
		"message": "Logout successful",
		"status":  "success",
	})
}
