package controllers

import (
	"anak_kos/config"
	"anak_kos/models"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"net/http"

	"github.com/jinzhu/copier"
	"github.com/labstack/echo/v4"
	"golang.org/x/crypto/bcrypt"
)

func Login(c echo.Context) error {
	// Bind request payload
	var loginRequest models.LoginRequest
	if err := c.Bind(&loginRequest); err != nil {
		return c.JSON(http.StatusBadRequest, echo.Map{
			"message": "Invalid request payload",
			"status":  "error",
			"success": false,
			"data":    err.Error(),
		})
	}

	// Find user by email
	var user models.User
	if err := config.DB.Where("email = ?", loginRequest.Email).First(&user).Error; err != nil {
		return c.JSON(http.StatusUnauthorized, echo.Map{
			"message": "Invalid email or password",
			"status":  "error",
			"success": false,
		})
	}

	// Compare password
	if err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(loginRequest.Password)); err != nil {
		return c.JSON(http.StatusUnauthorized, echo.Map{
			"message": "Invalid email or password",
			"status":  "error",
			"success": false,
		})
	}

	// Generate token
	userInfo := models.UserResponse{}
	if err := copier.Copy(&userInfo, &user); err != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{
			"message": "Failed to process user data",
			"status":  "error",
			"success": false,
		})
	}

	fmt.Println("User Info:", userInfo)

	userInfoJSON, err := json.Marshal(userInfo)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{
			"message": "Failed to serialize user info",
			"status":  "error",
			"success": false,
		})
	}

	token := base64.StdEncoding.EncodeToString(userInfoJSON)

	loginResponse := models.LoginResponse{
		Token: token,
		User:  userInfo,
	}

	// Return response with token
	return c.JSON(http.StatusOK, echo.Map{
		"message": "Login successful",
		"status":  "success",
		"success": true,
		"data":    loginResponse,
	})
}

func Register(c echo.Context) error {
	// Bind request payload
	var registerRequest models.RegisterRequest
	if err := c.Bind(&registerRequest); err != nil {
		return c.JSON(http.StatusBadRequest, echo.Map{
			"message": "Invalid request body",
			"status":  "error",
			"success": false,
			"data":    err.Error(),
		})
	}

	// Check if user already exists
	var existingUser models.User
	if err := config.DB.Where("email = ?", registerRequest.Email).First(&existingUser).Error; err == nil {
		return c.JSON(http.StatusConflict, echo.Map{
			"message": "User already exists",
			"status":  "error",
			"success": false,
		})
	}

	// Copy request data to user model
	user := models.User{}
	if err := copier.Copy(&user, &registerRequest); err != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{
			"message": "Failed to process registration data",
			"status":  "error",
			"success": false,
		})
	}

	// Save user to database
	if err := config.DB.Create(&user).Error; err != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{
			"message": "Failed to register user",
			"status":  "error",
			"success": false,
		})
	}

	// Copy user data to response struct
	registerResponse := models.RegisterResponse{}
	if err := copier.Copy(&registerResponse, &user); err != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{
			"message": "Failed to process response data",
			"status":  "error",
			"success": false,
		})
	}

	// Return response
	return c.JSON(http.StatusOK, echo.Map{
		"message": "Registration successful",
		"status":  "success",
		"success": true,
		"user":    registerResponse,
	})
}

func Logout(c echo.Context) error {
	// No cookies to clear, just return success
	return c.JSON(http.StatusOK, echo.Map{
		"message": "Logout successful",
		"status":  "success",
		"success": true,
	})
}
