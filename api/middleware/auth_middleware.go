package middleware

import (
	"anak_kos/context"
	"encoding/base64"
	"encoding/json"
	"net/http"

	"github.com/labstack/echo/v4"
)

func AuthMiddleware(next echo.HandlerFunc) echo.HandlerFunc {
	return func(c echo.Context) error {
		sessionCookie, err := c.Cookie("session_id")
		if err != nil || sessionCookie.Value == "" {
			return c.JSON(http.StatusUnauthorized, echo.Map{"error": "Unauthorized"})
		}

		userCookie, err := c.Cookie("user_info")
		if err != nil || userCookie.Value == "" {
			return c.JSON(http.StatusUnauthorized, echo.Map{"error": "User information not found"})
		}

		decodedUserInfo, err := base64.StdEncoding.DecodeString(userCookie.Value)
		if err != nil {
			return c.JSON(http.StatusUnauthorized, echo.Map{"error": "Failed to decode user information"})
		}

		var user context.AuthenticatedUser
		if err := json.Unmarshal(decodedUserInfo, &user); err != nil {
			return c.JSON(http.StatusUnauthorized, echo.Map{"error": "Failed to parse user information"})
		}

		// Inject ke context
		c.Set("user", user)

		return next(c)
	}
}
