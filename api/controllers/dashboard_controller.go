package controllers

import (
	"anak_kos/config"
	"anak_kos/context"
	"anak_kos/models"
	"net/http"

	"github.com/labstack/echo/v4"
)

func GetDashboard(c echo.Context) error {
	user := c.Get("user").(context.AuthenticatedUser)
	role := user.Role
	userID := user.ID.String()

	if role == string(models.RoleOwner) {
		var pending, confirmed, cancelled int64
		config.DB.Model(&models.Booking{}).
			Preload("User").
			Preload("BoardingHouse").
			Joins("JOIN boarding_houses ON bookings.boarding_house_id = boarding_houses.id").
			Where("boarding_houses.owner_id = ? AND bookings.status = ?", userID, models.BookingPending).
			Count(&pending)
		config.DB.Model(&models.Booking{}).
			Preload("User").
			Preload("BoardingHouse").
			Joins("JOIN boarding_houses ON bookings.boarding_house_id = boarding_houses.id").
			Where("boarding_houses.owner_id = ? AND bookings.status = ?", userID, models.BookingConfirmed).
			Count(&confirmed)
		config.DB.Model(&models.Booking{}).
			Preload("User").
			Preload("BoardingHouse").
			Joins("JOIN boarding_houses ON bookings.boarding_house_id = boarding_houses.id").
			Where("boarding_houses.owner_id = ? AND bookings.status = ?", userID, models.BookingCancelled).
			Count(&cancelled)

		return c.JSON(http.StatusOK, echo.Map{
			"data": echo.Map{
				"pending":   pending,
				"confirmed": confirmed,
				"cancelled": cancelled,
			},
			"message": "Dashboard data retrieved successfully",
			"status":  "success",
		})
	}

	return c.JSON(http.StatusOK, echo.Map{
		"data":    nil,
		"message": "Dashboard data not available for this user role",
		"status":  "success",
	})
}
