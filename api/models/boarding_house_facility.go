package models

import "github.com/google/uuid"

type BoardingHouseFacility struct {
	BoardingHouseID uuid.UUID `gorm:"type:char(36);primaryKey" json:"boarding_house_id"`
	FacilityID      uuid.UUID `gorm:"type:char(36);primaryKey" json:"facility_id"`

	Facility Facility `gorm:"foreignKey:FacilityID"`
}

// BoardingHouseFacilityRequest represents the request payload for associating a Facility with a BoardingHouse
type BoardingHouseFacilityRequest struct {
	BoardingHouseID string `json:"boarding_house_id" binding:"required,uuid"`
	FacilityID      string `json:"facility_id" binding:"required,uuid"`
}

// BoardingHouseFacilityResponse represents the response payload for a BoardingHouseFacility
type BoardingHouseFacilityResponse struct {
	BoardingHouseID string           `json:"boarding_house_id"`
	FacilityID      string           `json:"facility_id"`
	Facility        FacilityResponse `json:"facility"`
}
