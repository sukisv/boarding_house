package main

import (
	"log"
	"os"

	"anak_kos/config"
	"anak_kos/routes"

	"github.com/joho/godotenv"
	"github.com/labstack/echo/v4"
	"github.com/labstack/echo/v4/middleware"
)

func main() {
	if err := godotenv.Load(); err != nil {
		log.Fatal("Error loading .env")
	}

	config.SetupDatabase()

	e := echo.New()

	e.Static("/uploads", "uploads")

	e.Use(middleware.CORSWithConfig(middleware.CORSConfig{
		AllowOrigins:     []string{"*"},
		AllowMethods:     []string{echo.GET, echo.POST, echo.PUT, echo.DELETE},
		AllowCredentials: true,
	}))

	routes.InitRoutes(e)

	port := os.Getenv("APP_PORT")
	e.Logger.Fatal(e.Start(":" + port))
}
