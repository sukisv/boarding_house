package controllers

import (
	"anak_kos/config"
	"anak_kos/models"
	"net/http"

	"github.com/google/uuid"
	"github.com/labstack/echo/v4"
)

func GetMe(c echo.Context) error {
	user, ok := c.Get("user").(map[string]interface{})
	if !ok || user == nil {
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
	return c.JSON(http.StatusOK, echo.Map{
		"message": "Successfully retrieved users",
		"status":  "success",
		"data":    users,
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
	return c.JSON(http.StatusOK, echo.Map{
		"message": "Successfully retrieved user",
		"status":  "success",
		"data":    user,
	})
}

func CreateUser(c echo.Context) error {
	user := new(models.User)
	if err := c.Bind(user); err != nil {
		return c.JSON(http.StatusBadRequest, echo.Map{
			"message": "Failed to parse request body",
			"status":  "error",
			"data":    err.Error(),
		})
	}
	user.ID = uuid.New()

	if err := config.DB.Create(user).Error; err != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{
			"message": "Failed to create user",
			"status":  "error",
			"data":    err.Error(),
		})
	}
	return c.JSON(http.StatusCreated, echo.Map{
		"message": "User created successfully",
		"status":  "success",
		"data":    user,
	})
}

func UpdateUser(c echo.Context) error {
	id := c.Param("id")
	var user models.User

	if err := config.DB.First(&user, "id = ?", id).Error; err != nil {
		return c.JSON(http.StatusNotFound, echo.Map{
			"message": "User not found",
			"status":  "error",
			"data":    nil,
		})
	}

	if err := c.Bind(&user); err != nil {
		return c.JSON(http.StatusBadRequest, echo.Map{
			"message": "Failed to parse request body",
			"status":  "error",
			"data":    err.Error(),
		})
	}

	if err := config.DB.Save(&user).Error; err != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{
			"message": "Failed to update user",
			"status":  "error",
			"data":    err.Error(),
		})
	}
	return c.JSON(http.StatusOK, echo.Map{
		"message": "User updated successfully",
		"status":  "success",
		"data":    user,
	})
}

func DeleteUser(c echo.Context) error {
	id := c.Param("id")
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
