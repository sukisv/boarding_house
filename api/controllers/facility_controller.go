package controllers

import (
	"anak_kos/config"
	"anak_kos/models"
	"net/http"

	"github.com/labstack/echo/v4"
)

func GetFacilities(c echo.Context) error {
	var facilities []models.Facility
	if err := config.DB.Find(&facilities).Error; err != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{
			"message": "Failed to retrieve facilities",
			"status":  "error",
			"success": false,
			"data":    err.Error(),
		})
	}

	return c.JSON(http.StatusOK, echo.Map{
		"message": "Successfully retrieved facilities",
		"status":  "success",
		"success": true,
		"data":    facilities,
	})
}

func GetFacilityByID(c echo.Context) error {
	id := c.Param("id")
	var facility models.Facility
	if err := config.DB.First(&facility, "id = ?", id).Error; err != nil {
		return c.JSON(http.StatusNotFound, echo.Map{
			"message": "Facility not found",
			"status":  "error",
			"success": false,
			"data":    nil,
		})
	}

	return c.JSON(http.StatusOK, echo.Map{
		"message": "Successfully retrieved facility",
		"status":  "success",
		"success": true,
		"data":    facility,
	})
}
