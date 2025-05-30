package controllers

import (
	"fmt"
	"net/http"
	"os"
	"path/filepath"
	"time"

	"anak_kos/config"
	"anak_kos/context"
	"anak_kos/models"

	"github.com/google/uuid"
	"github.com/jinzhu/copier"
	"github.com/labstack/echo/v4"
)

func UploadBoardingHouseImages(c echo.Context) error {
	user := c.Get("user").(context.AuthenticatedUser)
	userID := user.ID

	houseIDStr := c.FormValue("boarding_house_id")
	houseID, err := uuid.Parse(houseIDStr)
	if err != nil {
		return c.JSON(http.StatusBadRequest, echo.Map{
			"error":   "ID kos tidak valid",
			"success": false,
		})
	}

	var house models.BoardingHouse
	if err := config.DB.First(&house, "id = ?", houseID).Error; err != nil {
		return c.JSON(http.StatusNotFound, echo.Map{
			"error":   "Boarding house tidak ditemukan",
			"success": false,
		})
	}
	if house.OwnerID != userID {
		return c.JSON(http.StatusForbidden, echo.Map{
			"error":   "Kamu bukan pemilik kos ini",
			"success": false,
		})
	}

	form, err := c.MultipartForm()
	if err != nil {
		return c.JSON(http.StatusBadRequest, echo.Map{
			"error":   "Gagal membaca form data",
			"success": false,
		})
	}
	files := form.File["images"]

	if len(files) == 0 {
		return c.JSON(http.StatusBadRequest, echo.Map{
			"error":   "Tidak ada gambar yang dikirim",
			"success": false,
		})
	}

	uploadDir := "uploads"
	if _, err := os.Stat(uploadDir); os.IsNotExist(err) {
		os.Mkdir(uploadDir, os.ModePerm)
	}

	var uploadedImages []models.BoardingHouseImageResponse

	for _, file := range files {
		src, err := file.Open()
		if err != nil {
			continue
		}
		defer src.Close()

		filename := fmt.Sprintf("%s%s", uuid.New().String(), filepath.Ext(file.Filename))
		savePath := filepath.Join(uploadDir, filename)

		dst, err := os.Create(savePath)
		if err != nil {
			continue
		}
		defer dst.Close()

		if _, err := dst.ReadFrom(src); err != nil {
			continue
		}

		image := models.BoardingHouseImage{
			BoardingHouseID: houseID,
			ImageURL:        "/" + savePath,
			CreatedAt:       time.Now(),
		}

		if err := config.DB.Create(&image).Error; err == nil {
			var imageResponse models.BoardingHouseImageResponse
			if err := copier.Copy(&imageResponse, &image); err == nil {
				uploadedImages = append(uploadedImages, imageResponse)
			}
		}
	}

	if len(uploadedImages) == 0 {
		return c.JSON(http.StatusInternalServerError, echo.Map{
			"error":   "Tidak ada gambar yang berhasil diupload",
			"success": false,
		})
	}

	return c.JSON(http.StatusOK, echo.Map{
		"message": "Gambar berhasil diupload",
		"data":    uploadedImages,
		"success": true,
	})
}

func GetImagesByBoardingHouseID(c echo.Context) error {
	houseID := c.Param("id")
	var images []models.BoardingHouseImage

	if err := config.DB.Where("boarding_house_id = ?", houseID).Find(&images).Error; err != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{"error": "Gagal mengambil gambar"})
	}

	var responseImages []models.BoardingHouseImageResponse
	if err := copier.Copy(&responseImages, &images); err != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{"error": "Gagal memproses data gambar"})
	}

	return c.JSON(http.StatusOK, echo.Map{
		"message": "Daftar gambar",
		"data":    responseImages,
		"status":  "success",
		"success": true,
	})
}

func DeleteBoardingHouseImage(c echo.Context) error {
	userCtx := c.Get("user").(context.AuthenticatedUser)
	userID := userCtx.ID

	imageID := c.Param("id")

	var image models.BoardingHouseImage
	if err := config.DB.First(&image, "id = ?", imageID).Error; err != nil {
		return c.JSON(http.StatusNotFound, echo.Map{
			"message": "Gambar tidak ditemukan",
			"status":  "error",
			"success": false,
		})
	}

	var house models.BoardingHouse
	if err := config.DB.First(&house, "id = ?", image.BoardingHouseID).Error; err != nil {
		return c.JSON(http.StatusNotFound, echo.Map{
			"message": "Boarding house tidak ditemukan",
			"status":  "error",
			"success": false,
		})
	}

	if house.OwnerID != userID {
		return c.JSON(http.StatusForbidden, echo.Map{
			"message": "Kamu tidak punya akses untuk menghapus gambar ini",
			"status":  "error",
			"success": false,
		})
	}

	if image.ImageURL != "" {
		path := "." + image.ImageURL
		if err := os.Remove(path); err != nil && !os.IsNotExist(err) {
			return c.JSON(http.StatusInternalServerError, echo.Map{
				"message": "Gagal menghapus file gambar",
				"status":  "error",
				"data":    err.Error(),
				"success": false,
			})
		}
	}

	if err := config.DB.Delete(&image).Error; err != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{
			"message": "Gagal menghapus gambar",
			"status":  "error",
			"data":    err.Error(),
			"succes":  false,
		})
	}

	return c.JSON(http.StatusOK, echo.Map{
		"message": "Gambar berhasil dihapus",
		"status":  "success",
		"success": true,
	})
}
