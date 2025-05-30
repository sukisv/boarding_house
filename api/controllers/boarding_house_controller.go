package controllers

import (
	"anak_kos/config"
	"anak_kos/context"
	"anak_kos/models"
	"net/http"
	"reflect"
	"strconv"
	"time"

	"github.com/google/uuid"
	"github.com/jinzhu/copier"
	"github.com/labstack/echo/v4"
)

type BoardingHousePayload struct {
	OwnerID       uuid.UUID   `json:"owner_id"`
	Name          string      `json:"name"`
	Description   string      `json:"description"`
	Address       string      `json:"address"`
	City          string      `json:"city"`
	PricePerMonth float64     `json:"price_per_month"`
	RoomAvailable int         `json:"room_available"`
	GenderAllowed string      `json:"gender_allowed"`
	FacilityIDs   []uuid.UUID `json:"facility_ids"`
}

// GET /api/boarding-houses?page=2&limit=5&search=kos&city=Jakarta&min_price=1000000&gender_allowed=mixed

func GetBoardingHouses(c echo.Context) error {
	user := c.Get("user").(context.AuthenticatedUser)
	userID := user.ID.String()
	userRole := string(user.Role)

	pageParam := c.QueryParam("page")
	limitParam := c.QueryParam("limit")

	page, err := strconv.Atoi(pageParam)
	if err != nil || page < 1 {
		page = 1
	}
	limit, err := strconv.Atoi(limitParam)
	if err != nil || limit < 1 {
		limit = 10
	}
	offset := (page - 1) * limit

	db := config.DB.
		Model(&models.BoardingHouse{}).
		Preload("Owner").
		Preload("Facilities").
		Preload("Images").
		Where("deleted_at IS NULL")

	if userRole == string(models.RoleOwner) {
		db = db.Where("owner_id = ?", userID)
	}

	// Dynamically generate filters from model fields
	boardingHouseType := reflect.TypeOf(models.BoardingHouse{})
	for i := 0; i < boardingHouseType.NumField(); i++ {
		field := boardingHouseType.Field(i)
		column := field.Tag.Get("json")
		if column == "" {
			continue
		}
		if value := c.QueryParam(column); value != "" {
			db = db.Where(column+" = ?", value)
		}
	}

	if minPriceParam := c.QueryParam("min_price"); minPriceParam != "" {
		if minPrice, err := strconv.ParseFloat(minPriceParam, 64); err == nil {
			db = db.Where("price_per_month >= ?", minPrice)
		}
	}
	if maxPriceParam := c.QueryParam("max_price"); maxPriceParam != "" {
		if maxPrice, err := strconv.ParseFloat(maxPriceParam, 64); err == nil {
			db = db.Where("price_per_month <= ?", maxPrice)
		}
	}

	if userRole == string(models.RoleSeeker) {
		today := time.Now().Truncate(24 * time.Hour)

		subq := config.DB.
			Model(&models.Booking{}).
			Select("boarding_house_id, COUNT(*) AS booked_count").
			Where("status = ?", models.BookingConfirmed).
			Where("? BETWEEN start_date AND end_date", today).
			Group("boarding_house_id")

		db = db.Joins(
			"LEFT JOIN (?) AS booking_counts ON booking_counts.boarding_house_id = boarding_houses.id",
			subq,
		).Where(
			"IFNULL(booking_counts.booked_count, 0) < boarding_houses.room_available",
		)
	}

	var total int64
	if err := db.Count(&total).Error; err != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{
			"message": "Failed to count boarding houses",
			"status":  "error",
			"data":    []models.BoardingHouseResponse{},
		})
	}

	var houses []models.BoardingHouse
	if err := db.Limit(limit).Offset(offset).Find(&houses).Error; err != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{
			"message": "Failed to retrieve boarding houses",
			"status":  "error",
			"data":    []models.BoardingHouseResponse{},
		})
	}

	var responseHouses []models.BoardingHouseResponse
	for _, house := range houses {
		var bookedCount int64
		config.DB.Model(&models.Booking{}).
			Where("boarding_house_id = ? AND status = ? AND ? BETWEEN start_date AND end_date", house.ID, models.BookingConfirmed, time.Now()).
			Count(&bookedCount)
		availableCount := house.RoomAvailable - int(bookedCount)

		var resp models.BoardingHouseResponse
		copier.Copy(&resp, &house)
		resp.BookedCount = bookedCount
		resp.AvailableCount = availableCount

		responseHouses = append(responseHouses, resp)
	}

	totalPages := int((total + int64(limit) - 1) / int64(limit))

	return c.JSON(http.StatusOK, echo.Map{
		"message": "Successfully retrieved boarding houses",
		"status":  "success",
		"data":    responseHouses,
		"meta": echo.Map{
			"page":        page,
			"limit":       limit,
			"total":       total,
			"total_pages": totalPages,
		},
	})
}

func GetBoardingHouseByID(c echo.Context) error {
	id := c.Param("id")
	var house models.BoardingHouse
	if err := config.DB.
		Preload("Owner").
		Preload("Facilities").
		Preload("Images").
		First(&house, "id = ?", id).Error; err != nil {
		return c.JSON(http.StatusNotFound, echo.Map{
			"message": "Boarding house not found",
			"status":  "error",
			"data":    nil,
		})
	}

	var bookedCount int64
	config.DB.Model(&models.Booking{}).
		Where("boarding_house_id = ? AND status = ? AND ? BETWEEN start_date AND end_date", house.ID, models.BookingConfirmed, time.Now()).
		Count(&bookedCount)
	availableCount := house.RoomAvailable - int(bookedCount)

	var resp models.BoardingHouseResponse
	copier.Copy(&resp, &house)

	resp.BookedCount = bookedCount
	resp.AvailableCount = availableCount

	return c.JSON(http.StatusOK, echo.Map{
		"message": "Successfully retrieved boarding house",
		"status":  "success",
		"data":    resp,
	})
}

func CreateBoardingHouse(c echo.Context) error {
	// Get authenticated user
	user := c.Get("user").(context.AuthenticatedUser)

	// Bind request payload
	var request models.BoardingHouseRequest
	if err := c.Bind(&request); err != nil {
		return c.JSON(http.StatusBadRequest, echo.Map{
			"message": "Failed to read request",
			"status":  "error",
			"success": false,
			"data":    nil,
		})
	}

	// Copy request data to BoardingHouse model
	house := models.BoardingHouse{}
	if err := copier.Copy(&house, &request); err != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{
			"message": "Failed to process request data",
			"status":  "error",
			"data":    nil,
		})
	}

	// Set OwnerID from authenticated user
	house.OwnerID = user.ID

	// Save BoardingHouse to database
	if err := config.DB.Create(&house).Error; err != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{
			"message": "Failed to create boarding house",
			"status":  "error",
			"data":    nil,
		})
	}

	// Save facilities to the database
	for _, fid := range request.FacilityIDs {
		facilityID, err := uuid.Parse(fid)
		if err != nil {
			return c.JSON(http.StatusBadRequest, echo.Map{
				"message": "Invalid facility ID",
				"status":  "error",
				"data":    nil,
			})
		}
		facility := models.BoardingHouseFacility{
			BoardingHouseID: house.ID,
			FacilityID:      facilityID,
		}
		if err := config.DB.Create(&facility).Error; err != nil {
			return c.JSON(http.StatusInternalServerError, echo.Map{
				"message": "Failed to associate facilities",
				"status":  "error",
				"data":    nil,
			})
		}
	}

	// Copy BoardingHouse data to response struct
	response := models.BoardingHouseResponse{}
	if err := copier.Copy(&response, &house); err != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{
			"message": "Failed to process response data",
			"status":  "error",
			"data":    nil,
		})
	}

	// Return response
	return c.JSON(http.StatusCreated, echo.Map{
		"message": "Boarding house created successfully",
		"status":  "success",
		"data":    response,
	})
}

func UpdateBoardingHouse(c echo.Context) error {
	// Get authenticated user
	user := c.Get("user").(context.AuthenticatedUser)
	userID := user.ID.String()

	// Get boarding house ID from URL
	id := c.Param("id")
	var house models.BoardingHouse

	// Find boarding house by ID
	if err := config.DB.Preload("Facilities").
		First(&house, "id = ?", id).Error; err != nil {
		return c.JSON(http.StatusNotFound, echo.Map{
			"message": "Boarding house tidak ditemukan",
			"status":  "error",
			"data":    nil,
		})
	}

	// Check if the user is the owner
	if house.OwnerID.String() != userID {
		return c.JSON(http.StatusForbidden, echo.Map{
			"message": "Anda tidak memiliki hak untuk memperbarui boarding house ini",
			"status":  "error",
		})
	}

	// Bind request payload
	var p BoardingHousePayload
	if err := c.Bind(&p); err != nil {
		return c.JSON(http.StatusBadRequest, echo.Map{
			"message": "Gagal membaca request",
			"status":  "error",
			"data":    nil,
		})
	}

	// Update boarding house fields
	house.Name = p.Name
	house.Description = p.Description
	house.Address = p.Address
	house.City = p.City
	house.PricePerMonth = p.PricePerMonth
	house.RoomAvailable = p.RoomAvailable
	house.GenderAllowed = p.GenderAllowed

	// Save updated boarding house to database
	if err := config.DB.Save(&house).Error; err != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{
			"message": "Gagal memperbarui boarding house",
			"status":  "error",
			"data":    nil,
		})
	}

	// Update facilities
	config.DB.Where("boarding_house_id = ?", house.ID).Delete(&models.BoardingHouseFacility{})
	for _, fid := range p.FacilityIDs {
		facilityID, err := uuid.Parse(fid.String())
		if err != nil {
			return c.JSON(http.StatusBadRequest, echo.Map{
				"message": "Invalid facility ID",
				"status":  "error",
				"data":    nil,
			})
		}
		facility := models.BoardingHouseFacility{
			BoardingHouseID: house.ID,
			FacilityID:      facilityID,
		}
		if err := config.DB.Create(&facility).Error; err != nil {
			return c.JSON(http.StatusInternalServerError, echo.Map{
				"message": "Gagal memperbarui fasilitas",
				"status":  "error",
				"data":    nil,
			})
		}
	}

	// Reload boarding house with updated facilities
	config.DB.Preload("Facilities").First(&house, "id = ?", house.ID)

	// Return response
	return c.JSON(http.StatusOK, echo.Map{
		"message": "Boarding house diperbarui berhasil",
		"status":  "success",
		"data":    house,
	})
}

func DeleteBoardingHouse(c echo.Context) error {
	id := c.Param("id")
	var house models.BoardingHouse

	user := c.Get("user").(context.AuthenticatedUser)
	userID := user.ID.String()

	if err := config.DB.First(&house, "id = ?", id).Error; err != nil {
		return c.JSON(http.StatusNotFound, echo.Map{
			"message": "Boarding house not found",
			"status":  "error",
			"data":    nil,
		})
	}

	if house.OwnerID.String() != userID {
		return c.JSON(http.StatusUnauthorized, echo.Map{
			"message": "You are not authorized to delete this boarding house",
			"status":  "error",
			"data":    nil,
		})
	}

	if err := config.DB.Delete(&house).Error; err != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{
			"message": "Failed to delete boarding house",
			"status":  "error",
			"data":    nil,
		})
	}

	return c.JSON(http.StatusOK, echo.Map{
		"message": "Boarding house deleted successfully",
		"status":  "success",
		"data":    nil,
	})
}
