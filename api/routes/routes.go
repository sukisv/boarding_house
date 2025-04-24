package routes

import (
	"anak_kos/controllers"
	"anak_kos/middleware"

	"github.com/labstack/echo/v4"
)

func InitRoutes(e *echo.Echo) {
	// Welcome Route
	e.GET("/", func(c echo.Context) error {
		return c.String(200, "Welcome to My Boarding House API 🏠")
	})

	// Group for Register, Login, and Logout (No authentication needed)
	authGroup := e.Group("/auth")
	{
		authGroup.POST("/register", controllers.Register)
		authGroup.POST("/login", controllers.Login)
		authGroup.POST("/logout", controllers.Logout)
	}

	// Group for API endpoints that require authentication (using middleware)
	api := e.Group("/api", middleware.AuthMiddleware)
	{
		// Boarding Houses Routes
		api.GET("/boarding-houses", controllers.GetBoardingHouses)
		api.GET("/boarding-houses/:id", controllers.GetBoardingHouseByID)
		api.POST("/boarding-houses", controllers.CreateBoardingHouse)
		api.PUT("/boarding-houses/:id", controllers.UpdateBoardingHouse)
		api.DELETE("/boarding-houses/:id", controllers.DeleteBoardingHouse)

		// Users Routes
		api.GET("/users/me", controllers.GetMe)
		// api.GET("/users", controllers.GetUsers)
		// api.GET("/users/:id", controllers.GetUserByID)
		// api.POST("/users", controllers.CreateUser)
		// api.PUT("/users/:id", controllers.UpdateUser)
		// api.DELETE("/users/:id", controllers.DeleteUser)

		api.POST("/boarding-house-images", controllers.UploadBoardingHouseImages) // multiple upload
		api.PUT("/boarding-house-images/:boarding_house_id", controllers.DeleteBoardingHouseImage)
		api.DELETE("/boarding-house-images/:id", controllers.DeleteBoardingHouseImage)

		api.POST("/bookings", controllers.CreateBooking)
		api.GET("/bookings", controllers.GetBookings)
		api.GET("/bookings/:id", controllers.GetBookingByID)
		api.PUT("/bookings/:id", controllers.UpdateBooking)
	}
}
