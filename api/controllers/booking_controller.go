package controllers

import (
	"net/http"
	"time"

	"anak_kos/config"
	"anak_kos/context"
	"anak_kos/models"

	"github.com/google/uuid"
	"github.com/labstack/echo/v4"
)

func CreateBooking(c echo.Context) error {
	user := c.Get("user").(context.AuthenticatedUser)
	userID := user.ID.String()
	userRole := string(user.Role)

	if userRole != string(models.RoleSeeker) {
		return c.JSON(http.StatusForbidden, echo.Map{"message": "Only seekers can create bookings", "status": "error"})
	}

	var payload struct {
		BoardingHouseID uuid.UUID `json:"boarding_house_id"`
		StartDate       string    `json:"start_date"`
		EndDate         string    `json:"end_date"`
	}
	if err := c.Bind(&payload); err != nil {
		return c.JSON(http.StatusBadRequest, echo.Map{"message": "Invalid request body", "status": "error", "data": err.Error()})
	}

	start, err := time.Parse("2006-01-02", payload.StartDate)
	if err != nil {
		return c.JSON(http.StatusBadRequest, echo.Map{"message": "Invalid start_date format", "status": "error", "data": err.Error()})
	}
	end, err := time.Parse("2006-01-02", payload.EndDate)
	if err != nil {
		return c.JSON(http.StatusBadRequest, echo.Map{"message": "Invalid end_date format", "status": "error", "data": err.Error()})
	}
	if end.Before(start) {
		return c.JSON(http.StatusBadRequest, echo.Map{"message": "end_date must be after start_date", "status": "error"})
	}

	booking := models.Booking{
		UserID:          uuid.MustParse(userID),
		BoardingHouseID: payload.BoardingHouseID,
		StartDate:       start,
		EndDate:         end,
		Status:          models.BookingPending,
	}

	if err := config.DB.Create(&booking).Error; err != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{"message": "Failed to create booking", "status": "error", "data": err.Error()})
	}

	return c.JSON(http.StatusCreated, echo.Map{"message": "Booking created successfully", "status": "success", "data": booking})
}

func GetBookings(c echo.Context) error {
	userCtx := c.Get("user").(map[string]interface{})
	userID := userCtx["id"].(string)

	var bookings []models.Booking
	if err := config.DB.
		Preload("BoardingHouse").
		Where("user_id = ?", userID).
		Find(&bookings).Error; err != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{
			"message": "Failed to retrieve bookings",
			"status":  "error",
			"data":    err.Error(),
		})
	}

	return c.JSON(http.StatusOK, echo.Map{
		"message": "Successfully retrieved bookings",
		"status":  "success",
		"data":    bookings,
	})
}

func GetBookingByID(c echo.Context) error {
	userCtx := c.Get("user").(map[string]interface{})
	userID := userCtx["id"].(string)
	bookingID := c.Param("id")

	var booking models.Booking
	if err := config.DB.
		Preload("BoardingHouse").
		Where("id = ? AND user_id = ?", bookingID, userID).
		First(&booking).Error; err != nil {
		return c.JSON(http.StatusNotFound, echo.Map{
			"message": "Booking not found",
			"status":  "error",
		})
	}

	return c.JSON(http.StatusOK, echo.Map{
		"message": "Successfully retrieved booking",
		"status":  "success",
		"data":    booking,
	})
}

func UpdateBooking(c echo.Context) error {
	userCtx := c.Get("user").(map[string]interface{})
	userID := userCtx["id"].(string)
	bookingID := c.Param("id")

	var booking models.Booking
	if err := config.DB.
		Where("id = ? AND user_id = ?", bookingID, userID).
		First(&booking).Error; err != nil {
		return c.JSON(http.StatusNotFound, echo.Map{
			"message": "Booking not found",
			"status":  "error",
		})
	}

	if booking.Status != models.BookingPending {
		return c.JSON(http.StatusBadRequest, echo.Map{
			"message": "Only pending bookings can be updated",
			"status":  "error",
		})
	}

	var payload struct {
		StartDate string `json:"start_date"`
		EndDate   string `json:"end_date"`
	}
	if err := c.Bind(&payload); err != nil {
		return c.JSON(http.StatusBadRequest, echo.Map{
			"message": "Invalid request body",
			"status":  "error",
			"data":    err.Error(),
		})
	}

	if payload.StartDate != "" {
		if t, err := time.Parse("2006-01-02", payload.StartDate); err == nil {
			booking.StartDate = t
		}
	}
	if payload.EndDate != "" {
		if t, err := time.Parse("2006-01-02", payload.EndDate); err == nil {
			booking.EndDate = t
		}
	}

	if err := config.DB.Save(&booking).Error; err != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{
			"message": "Failed to update booking",
			"status":  "error",
			"data":    err.Error(),
		})
	}

	return c.JSON(http.StatusOK, echo.Map{
		"message": "Booking updated successfully",
		"status":  "success",
		"data":    booking,
	})
}

func DeleteBooking(c echo.Context) error {
	userCtx := c.Get("user").(map[string]interface{})
	userID := userCtx["id"].(string)
	bookingID := c.Param("id")

	if err := config.DB.
		Where("id = ? AND user_id = ?", bookingID, userID).
		Delete(&models.Booking{}).Error; err != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{
			"message": "Failed to delete booking",
			"status":  "error",
			"data":    err.Error(),
		})
	}

	return c.JSON(http.StatusOK, echo.Map{
		"message": "Booking cancelled successfully",
		"status":  "success",
	})
}

func UpdateBookingStatus(c echo.Context) error {
	bookingID := c.Param("id")
	var req struct {
		Status models.BookingStatus `json:"status"`
	}
	if err := c.Bind(&req); err != nil {
		return c.JSON(http.StatusBadRequest, echo.Map{
			"message": "Invalid request format",
			"status":  "error",
		})
	}

	var booking models.Booking
	if err := config.DB.
		Preload("BoardingHouse").
		First(&booking, "id = ?", bookingID).Error; err != nil {
		return c.JSON(http.StatusNotFound, echo.Map{
			"message": "Booking not found",
			"status":  "error",
		})
	}

	userCtx := c.Get("user").(map[string]interface{})
	userID := userCtx["id"].(string)
	if booking.BoardingHouse.OwnerID.String() != userID {
		return c.JSON(http.StatusForbidden, echo.Map{
			"message": "You are not authorized to update this booking",
			"status":  "error",
		})
	}

	booking.Status = req.Status
	if err := config.DB.Save(&booking).Error; err != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{
			"message": "Failed to update booking status",
			"status":  "error",
		})
	}

	return c.JSON(http.StatusOK, echo.Map{
		"message": "Booking status updated",
		"status":  "success",
		"data":    booking,
	})
}
