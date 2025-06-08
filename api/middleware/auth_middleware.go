package middleware

import (
	"anak_kos/context"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"net/http"
	"strings"

	"github.com/labstack/echo/v4"
)

func AuthMiddleware(next echo.HandlerFunc) echo.HandlerFunc {
	return func(c echo.Context) error {
		authHeader := c.Request().Header.Get("Authorization")
		if authHeader == "" || !strings.HasPrefix(authHeader, "Bearer ") {
			return c.JSON(http.StatusUnauthorized, echo.Map{"error": "Unauthorized"})
		}

		token := strings.TrimPrefix(authHeader, "Bearer ")
		decodedUserInfo, err := base64.StdEncoding.DecodeString(token)
		if err != nil {
			return c.JSON(http.StatusUnauthorized, echo.Map{"error": "Failed to decode token"})
		}

		var user context.AuthenticatedUser
		fmt.Println("Decoded User Info:", string(decodedUserInfo))
		if err := json.Unmarshal(decodedUserInfo, &user); err != nil {
			return c.JSON(http.StatusUnauthorized, echo.Map{"error": "Failed to parse token"})
		}

		// Inject ke context
		c.Set("user", user)

		return next(c)
	}
}
