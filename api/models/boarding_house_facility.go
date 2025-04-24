package models

import "github.com/google/uuid"

type BoardingHouseFacility struct {
	BoardingHouseID uuid.UUID `gorm:"type:char(36);primaryKey" json:"boarding_house_id"`
	FacilityID      uuid.UUID `gorm:"type:char(36);primaryKey" json:"facility_id"`

	Facility Facility `gorm:"foreignKey:FacilityID"`
}
