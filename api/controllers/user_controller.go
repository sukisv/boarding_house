package controllers

import (
	"anak_kos/config"
	"anak_kos/models"
	"net/http"

	"github.com/google/uuid"
	"github.com/jinzhu/copier"
	"github.com/labstack/echo/v4"
)

func GetMe(c echo.Context) error {
	user, ok := c.Get("user").(models.UserResponse)
	if !ok {
		return c.JSON(http.StatusUnauthorized, echo.Map{
			"message": "Unauthorized",
			"status":  "error",
			"data":    nil,
		})
	}

	return c.JSON(http.StatusOK, echo.Map{
		"message": "User profile fetched successfully",
		"status":  "success",
		"data":    user,
	})
}

func GetUsers(c echo.Context) error {
	var users []models.User
	if err := config.DB.Find(&users).Error; err != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{
			"message": "Failed to retrieve users",
			"status":  "error",
			"data":    err.Error(),
		})
	}

	var responseUsers []models.UserResponse
	if err := copier.Copy(&responseUsers, &users); err != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{
			"message": "Failed to process response data",
			"status":  "error",
			"data":    err.Error(),
		})
	}

	return c.JSON(http.StatusOK, echo.Map{
		"message": "Successfully retrieved users",
		"status":  "success",
		"data":    responseUsers,
	})
}

func GetUserByID(c echo.Context) error {
	id := c.Param("id")
	var user models.User

	if err := config.DB.First(&user, "id = ?", id).Error; err != nil {
		return c.JSON(http.StatusNotFound, echo.Map{
			"message": "User not found",
			"status":  "error",
			"data":    nil,
		})
	}

	var responseUser models.UserResponse
	if err := copier.Copy(&responseUser, &user); err != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{
			"message": "Failed to process response data",
			"status":  "error",
			"data":    err.Error(),
		})
	}

	return c.JSON(http.StatusOK, echo.Map{
		"message": "Successfully retrieved user",
		"status":  "success",
		"data":    responseUser,
	})
}

func CreateUser(c echo.Context) error {
	// Bind request payload
	var request models.UserRequest
	if err := c.Bind(&request); err != nil {
		return c.JSON(http.StatusBadRequest, echo.Map{
			"message": "Failed to parse request body",
			"status":  "error",
			"data":    err.Error(),
		})
	}

	// Copy request data to user model
	user := models.User{}
	if err := copier.Copy(&user, &request); err != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{
			"message": "Failed to process request data",
			"status":  "error",
			"data":    err.Error(),
		})
	}
	user.ID = uuid.New()

	// Save user to database
	if err := config.DB.Create(&user).Error; err != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{
			"message": "Failed to create user",
			"status":  "error",
			"data":    err.Error(),
		})
	}

	// Copy user data to response struct
	var responseUser models.UserResponse
	if err := copier.Copy(&responseUser, &user); err != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{
			"message": "Failed to process response data",
			"status":  "error",
			"data":    err.Error(),
		})
	}

	return c.JSON(http.StatusCreated, echo.Map{
		"message": "User created successfully",
		"status":  "success",
		"data":    responseUser,
	})
}

func UpdateUser(c echo.Context) error {
	id := c.Param("id")
	var user models.User

	// Find user by ID
	if err := config.DB.First(&user, "id = ?", id).Error; err != nil {
		return c.JSON(http.StatusNotFound, echo.Map{
			"message": "User not found",
			"status":  "error",
			"data":    nil,
		})
	}

	// Bind request payload
	var request models.UserRequest
	if err := c.Bind(&request); err != nil {
		return c.JSON(http.StatusBadRequest, echo.Map{
			"message": "Failed to parse request body",
			"status":  "error",
			"data":    err.Error(),
		})
	}

	// Copy request data to user model
	if err := copier.Copy(&user, &request); err != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{
			"message": "Failed to process request data",
			"status":  "error",
			"data":    err.Error(),
		})
	}

	// Save updated user to database
	if err := config.DB.Save(&user).Error; err != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{
			"message": "Failed to update user",
			"status":  "error",
			"data":    err.Error(),
		})
	}

	// Copy user data to response struct
	var responseUser models.UserResponse
	if err := copier.Copy(&responseUser, &user); err != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{
			"message": "Failed to process response data",
			"status":  "error",
			"data":    err.Error(),
		})
	}

	return c.JSON(http.StatusOK, echo.Map{
		"message": "User updated successfully",
		"status":  "success",
		"data":    responseUser,
	})
}

func DeleteUser(c echo.Context) error {
	id := c.Param("id")

	// Delete user by ID
	if err := config.DB.Delete(&models.User{}, "id = ?", id).Error; err != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{
			"message": "Failed to delete user",
			"status":  "error",
			"data":    err.Error(),
		})
	}

	return c.JSON(http.StatusOK, echo.Map{
		"message": "User deleted successfully",
		"status":  "success",
		"data":    nil,
	})
}
