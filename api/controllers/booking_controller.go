package controllers

import (
	"fmt"
	"net/http"
	"strconv"
	"time"

	"anak_kos/config"
	"anak_kos/context"
	"anak_kos/models"

	"github.com/google/uuid"
	"github.com/jinzhu/copier"
	"github.com/labstack/echo/v4"
)

func CreateBooking(c echo.Context) error {
	// Get authenticated user
	user := c.Get("user").(context.AuthenticatedUser)
	fmt.Println("Authenticated User:", user)
	userID := user.ID.String()
	userRole := string(user.Role)

	// Check if user is a seeker
	if userRole != string(models.RoleSeeker) {
		return c.JSON(http.StatusForbidden, echo.Map{
			"message": "Only seekers can create bookings",
			"status":  "error",
			"success": false,
		})
	}

	// Bind request payload
	var payload models.BookingRequest
	if err := c.Bind(&payload); err != nil {
		return c.JSON(http.StatusBadRequest, echo.Map{
			"message": "Invalid request body",
			"status":  "error",
			"success": false,
			"data":    err.Error(),
		})
	}

	// Parse dates from string input
	start, err := time.Parse("2006-01-02", payload.StartDate)
	if err != nil {
		return c.JSON(http.StatusBadRequest, echo.Map{
			"message": "Invalid start_date format, use YYYY-MM-DD",
			"status":  "error",
			"success": false,
			"data":    err.Error(),
		})
	}
	end, err := time.Parse("2006-01-02", payload.EndDate)
	if err != nil {
		return c.JSON(http.StatusBadRequest, echo.Map{
			"message": "Invalid end_date format, use YYYY-MM-DD",
			"status":  "error",
			"success": false,
			"data":    err.Error(),
		})
	}
	if end.Before(start) {
		return c.JSON(http.StatusBadRequest, echo.Map{
			"message": "end_date must be after start_date",
			"status":  "error",
			"success": false,
		})
	}

	// Create booking
	booking := models.Booking{
		UserID:          uuid.MustParse(userID),
		BoardingHouseID: uuid.MustParse(payload.BoardingHouseID),
		StartDate:       start,
		EndDate:         end,
		Status:          models.BookingPending,
	}

	// Save booking to database
	if err := config.DB.Create(&booking).Error; err != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{
			"message": "Failed to create booking",
			"status":  "error",
			"success": false,
			"data":    err.Error(),
		})
	}

	// Copy booking data to response struct
	response := models.BookingResponse{}
	if err := copier.Copy(&response, &booking); err != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{
			"message": "Failed to process response data",
			"status":  "error",
			"success": false,
			"data":    err.Error(),
		})
	}

	// Return response
	return c.JSON(http.StatusCreated, echo.Map{
		"message": "Booking created successfully",
		"status":  "success",
		"success": true,
		"data":    response,
	})
}

func GetBookings(c echo.Context) error {
	user := c.Get("user").(context.AuthenticatedUser)
	userID := user.ID.String()
	userRole := string(user.Role)

	search := c.QueryParam("search")
	status := c.QueryParam("status")
	pageParam := c.QueryParam("page")
	limitParam := c.QueryParam("limit")

	limit := 10
	page := 1
	if limitParam != "" {
		if l, err := strconv.Atoi(limitParam); err == nil && l > 0 {
			limit = l
		}
	}
	if pageParam != "" {
		if p, err := strconv.Atoi(pageParam); err == nil && p > 0 {
			page = p
		}
	}
	offset := (page - 1) * limit

	var bookings []models.Booking
	db := config.DB.Model(&models.Booking{})

	if userRole == string(models.RoleSeeker) {
		db = db.Preload("BoardingHouse").Preload("BoardingHouse.Images").Preload("BoardingHouse.Facilities").Preload("BoardingHouse.Owner").Preload("User").Where("user_id = ?", userID)
	} else if userRole == string(models.RoleOwner) {
		db = db.Preload("User").Preload("BoardingHouse").Joins("JOIN boarding_houses ON bookings.boarding_house_id = boarding_houses.id").Where("boarding_houses.owner_id = ?", userID)
	} else {
		return c.JSON(http.StatusForbidden, echo.Map{
			"message": "Unauthorized access",
			"status":  "error",
			"success": false,
		})
	}

	// Filter by status
	if status != "" {
		db = db.Where("bookings.status = ?", status)
	}

	if search != "" {
		db = db.Joins("LEFT JOIN users ON bookings.user_id = users.id").Joins("LEFT JOIN boarding_houses bh ON bookings.boarding_house_id = bh.id").Where("users.name ILIKE ? OR bh.name ILIKE ?", "%"+search+"%", "%"+search+"%")
	}

	var total int64
	db.Count(&total)

	totalPages := int((total + int64(limit) - 1) / int64(limit))

	if err := db.Limit(limit).Offset(offset).Find(&bookings).Error; err != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{
			"message": "Failed to retrieve bookings",
			"status":  "error",
			"success": false,
			"data":    err.Error(),
		})
	}

	var responseBookings []models.BookingResponse
	if err := copier.Copy(&responseBookings, &bookings); err != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{
			"message": "Failed to process response data",
			"status":  "error",
			"success": false,
			"data":    err.Error(),
		})
	}

	return c.JSON(http.StatusOK, echo.Map{
		"message": "Successfully retrieved bookings",
		"status":  "success",
		"success": true,
		"data":    responseBookings,
		"meta": echo.Map{
			"page":        page,
			"limit":       limit,
			"total":       total,
			"total_pages": totalPages,
		},
	})
}

func GetBookingByID(c echo.Context) error {
	user := c.Get("user").(context.AuthenticatedUser)
	userID := user.ID.String()
	userRole := string(user.Role)
	bookingID := c.Param("id")

	var booking models.Booking
	db := config.DB.Preload("BoardingHouse").Preload("User")

	if userRole == string(models.RoleSeeker) {
		db = db.Where("bookings.id = ? AND bookings.user_id = ?", bookingID, userID)
	} else if userRole == string(models.RoleOwner) {
		db = db.Joins("JOIN boarding_houses ON bookings.boarding_house_id = boarding_houses.id").Where("bookings.id = ? AND boarding_houses.owner_id = ?", bookingID, userID)
	} else {
		return c.JSON(http.StatusForbidden, echo.Map{
			"message": "Unauthorized access",
			"status":  "error",
			"success": false,
		})
	}

	if err := db.First(&booking).Error; err != nil {
		return c.JSON(http.StatusNotFound, echo.Map{
			"message": "Booking not found",
			"status":  "error",
			"success": false,
		})
	}

	response := models.BookingResponse{}
	if err := copier.Copy(&response, &booking); err != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{
			"message": "Failed to process response data",
			"status":  "error",
			"success": false,
			"data":    err.Error(),
		})
	}

	return c.JSON(http.StatusOK, echo.Map{
		"message": "Successfully retrieved booking",
		"status":  "success",
		"success": true,
		"data":    response,
	})
}

func UpdateBooking(c echo.Context) error {
	// Get authenticated user
	user := c.Get("user").(context.AuthenticatedUser)
	userID := user.ID.String()
	userRole := string(user.Role)
	bookingID := c.Param("id")

	// Hanya owner dari kos terkait yang bisa update booking
	if userRole != string(models.RoleOwner) {
		return c.JSON(http.StatusForbidden, echo.Map{"message": "Only owner can update booking", "status": "error"})
	}

	var booking models.Booking
	if err := config.DB.Preload("BoardingHouse").First(&booking, "id = ?", bookingID).Error; err != nil {
		return c.JSON(http.StatusNotFound, echo.Map{"message": "Booking not found", "status": "error"})
	}

	if booking.BoardingHouse.OwnerID.String() != userID {
		return c.JSON(http.StatusForbidden, echo.Map{"message": "You are not authorized to update this booking", "status": "error"})
	}

	if booking.Status != models.BookingPending {
		return c.JSON(http.StatusBadRequest, echo.Map{"message": "Only pending bookings can be updated", "status": "error"})
	}

	var payload models.BookingRequest
	if err := c.Bind(&payload); err != nil {
		return c.JSON(http.StatusBadRequest, echo.Map{"message": "Invalid request body", "status": "error", "data": err.Error()})
	}

	// Parse string date input
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

	if err := config.DB.Model(&booking).Omit("CreatedAt", "UpdatedAt").Save(&booking).Error; err != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{"message": "Failed to update booking", "status": "error", "data": err.Error()})
	}

	response := models.BookingResponse{}
	if err := copier.Copy(&response, &booking); err != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{"message": "Failed to process response data", "status": "error"})
	}

	return c.JSON(http.StatusOK, echo.Map{"message": "Booking updated successfully", "status": "success", "data": response})
}

func DeleteBooking(c echo.Context) error {
	user := c.Get("user").(context.AuthenticatedUser)
	userID := user.ID.String()
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
	user := c.Get("user").(context.AuthenticatedUser)
	userID := user.ID.String()
	userRole := string(user.Role)

	if userRole != string(models.RoleOwner) {
		return c.JSON(http.StatusForbidden, echo.Map{
			"message": "Only owner can update booking status",
			"status":  "error",
			"success": false,
		})
	}

	var req struct {
		Status models.BookingStatus `json:"status"`
	}
	if err := c.Bind(&req); err != nil {
		return c.JSON(http.StatusBadRequest, echo.Map{
			"message": "Invalid request format",
			"status":  "error",
			"success": false,
		})
	}

	var booking models.Booking
	if err := config.DB.
		Preload("BoardingHouse").
		First(&booking, "id = ?", bookingID).Error; err != nil {
		return c.JSON(http.StatusNotFound, echo.Map{
			"message": "Booking not found",
			"status":  "error",
			"success": false,
		})
	}

	if booking.BoardingHouse.OwnerID.String() != userID {
		return c.JSON(http.StatusForbidden, echo.Map{
			"message": "You are not authorized to update this booking",
			"status":  "error",
			"success": false,
		})
	}

	if booking.Status != models.BookingPending {
		return c.JSON(http.StatusBadRequest, echo.Map{
			"message": "Only pending bookings can be confirmed or cancelled",
			"status":  "error",
			"success": false,
		})
	}

	booking.Status = req.Status
	if err := config.DB.Model(&booking).Omit("CreatedAt", "UpdatedAt").Save(&booking).Error; err != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{
			"message": "Failed to update booking status",
			"status":  "error",
			"success": false,
		})
	}

	response := models.BookingResponse{}
	if err := copier.Copy(&response, &booking); err != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{
			"message": "Failed to process response data",
			"status":  "error",
			"success": false,
		})
	}

	return c.JSON(http.StatusOK, echo.Map{
		"message": "Booking status updated",
		"status":  "success",
		"success": true,
		"data":    response,
	})
}
