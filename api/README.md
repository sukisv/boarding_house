
# API Documentation - Anak Kos

This is the API for managing boarding houses, facilities, bookings, favorites, and more. It allows users to interact with boarding house data, owners, and facilities through a RESTful API.

## Table of Contents
1. [Getting Started](#getting-started)
2. [API Endpoints](#api-endpoints)
    - [Get All Boarding Houses](#get-all-boarding-houses)
    - [Get Boarding House By ID](#get-boarding-house-by-id)
    - [Create Boarding House](#create-boarding-house)
    - [Update Boarding House](#update-boarding-house)
    - [Delete Boarding House](#delete-boarding-house)
    - [Get All Facilities](#get-all-facilities)
    - [Get Facility By ID](#get-facility-by-id)
    - [Create Facility](#create-facility)
    - [Update Facility](#update-facility)
    - [Delete Facility](#delete-facility)
3. [Request Format](#request-format)
4. [Response Format](#response-format)
5. [Authentication](#authentication)

## Getting Started

Follow these instructions to get the API up and running locally.

### Prerequisites

- Go 1.16+
- MySQL Database

### Installation

Clone the repository:

```
git clone https://github.com/yourusername/anak_kos.git
cd anak_kos
```

Set up environment variables for your MySQL connection:

```
DB_USER=root
DB_PASSWORD=password
DB_HOST=localhost
DB_PORT=3306
DB_NAME=anak_kos_db
```

Install dependencies:

```
go mod tidy
```

Run the application:

```
go run main.go
```

## API Endpoints

### Get All Boarding Houses

**GET** `/boarding_houses`

Retrieve all boarding houses.

#### Query Parameters
- `page`: Optional. The page number for pagination.
- `limit`: Optional. The number of results per page for pagination.
- `filter`: Optional. Filter by city, price range, gender allowed.

#### Example Request
```bash
curl -X GET "http://localhost:8080/boarding_houses?page=1&limit=10&filter=jakarta"
```

#### Example Response
```json
{
    "message": "Successfully retrieved boarding houses",
    "status": "success",
    "data": [
        {
            "id": "3c47c7f7-203f-11f0-9584-e86a64eb7587",
            "name": "Boarding House A",
            "address": "Jl. ABC, Jakarta",
            "price_per_month": 1500000,
            "room_available": 5,
            "gender_allowed": "mixed",
            "owner": { ... },
            "facilities": [
                { "id": "3c47c7f7-203f-11f0-9584-e86a64eb7587", "name": "Wi-Fi" },
                { "id": "3c47c7f7-203f-11f0-9584-e86a64eb7587", "name": "AC" }
            ]
        }
    ]
}
```

### Get Boarding House By ID

**GET** `/boarding_houses/:id`

Retrieve a specific boarding house by its ID.

#### Example Request
```bash
curl -X GET "http://localhost:8080/boarding_houses/3c47c7f7-203f-11f0-9584-e86a64eb7587"
```

#### Example Response
```json
{
    "message": "Successfully retrieved boarding house",
    "status": "success",
    "data": { ... }
}
```

### Create Boarding House

**POST** `/boarding_houses`

Create a new boarding house.

#### Request Body
```json
{
    "name": "Boarding House A",
    "owner_id": "3c47c7f7-203f-11f0-9584-e86a64eb7587",
    "address": "Jl. ABC, Jakarta",
    "city": "Jakarta",
    "price_per_month": 1500000,
    "room_available": 5,
    "gender_allowed": "mixed",
    "facilities": [
        "3c47c7f7-203f-11f0-9584-e86a64eb7587",
        "3c47c7f7-203f-11f0-9584-e86a64eb7587"
    ]
}
```

#### Example Request
```bash
curl -X POST -H "Content-Type: application/json" -d '{
    "name": "Boarding House A",
    "owner_id": "3c47c7f7-203f-11f0-9584-e86a64eb7587",
    "address": "Jl. ABC, Jakarta",
    "city": "Jakarta",
    "price_per_month": 1500000,
    "room_available": 5,
    "gender_allowed": "mixed",
    "facilities": [
        "3c47c7f7-203f-11f0-9584-e86a64eb7587",
        "3c47c7f7-203f-11f0-9584-e86a64eb7587"
    ]
}' "http://localhost:8080/boarding_houses"
```

#### Example Response
```json
{
    "message": "Boarding house created successfully",
    "status": "success",
    "data": { ... }
}
```

### Update Boarding House

**PUT** `/boarding_houses/:id`

Update an existing boarding house.

#### Request Body
Same as "Create Boarding House".

#### Example Request
```bash
curl -X PUT -H "Content-Type: application/json" -d '{
    "name": "Updated Boarding House",
    "address": "Jl. XYZ, Jakarta",
    "price_per_month": 1800000,
    "room_available": 3,
    "gender_allowed": "male",
    "facilities": [
        "3c47c7f7-203f-11f0-9584-e86a64eb7587",
        "3c47c7f7-203f-11f0-9584-e86a64eb7587"
    ]
}' "http://localhost:8080/boarding_houses/3c47c7f7-203f-11f0-9584-e86a64eb7587"
```

### Delete Boarding House

**DELETE** `/boarding_houses/:id`

Delete a boarding house.

#### Example Request
```bash
curl -X DELETE "http://localhost:8080/boarding_houses/3c47c7f7-203f-11f0-9584-e86a64eb7587"
```

## Request Format

All requests should have the `Content-Type: application/json` header, and data should be in JSON format.

### Example Request Headers
```
Content-Type: application/json
Authorization: Bearer <token>
```

## Response Format

All responses will be returned in JSON format. A typical response includes a message, status, and data.

### Example Response
```json
{
    "message": "Successfully retrieved boarding houses",
    "status": "success",
    "data": { ... }
}
```

## Authentication

This API requires authentication for most operations. You can authenticate using JWT (JSON Web Token).

To authenticate, use the following request:

### Login
**POST** `/login`
```json
{
    "username": "yourusername",
    "password": "yourpassword"
}
```

#### Example Response
```json
{
    "message": "Login successful",
    "status": "success",
    "token": "<JWT_TOKEN>"
}
```

### JWT Authentication
Once you have the JWT token, include it in the `Authorization` header of your requests:

```
Authorization: Bearer <token>
```

