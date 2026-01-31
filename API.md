# Parking App API Documentation

This document lists all backend API endpoints available for the Parking App. These endpoints can be used by the mobile app or other services to interact with the backend system.

---

## Authentication

### Register
- **Endpoint:** `/auth/register`
- **Methods:** `POST`
- **Description:** Register a new user.
- **Request Body:**
  - `email`: string
  - `password`: string
  - `password_confirm`: string
- **Example Request (form-data):**
  ```http
  POST /auth/register
  Content-Type: application/x-www-form-urlencoded

  email=user@example.com&password=secret123&password_confirm=secret123
  ```
- **Example Response:**
  - On success: Redirects to login page with success message.
  - On error: Redirects back with error message (e.g., "Email already registered").

### Login
- **Endpoint:** `/auth/login`
- **Methods:** `POST`
- **Description:** Log in an existing user.
- **Request Body:**
  - `email`: string
  - `password`: string
- **Example Request (form-data):**
  ```http
  POST /auth/login
  Content-Type: application/x-www-form-urlencoded

  email=user@example.com&password=secret123
  ```
- **Example Response:**
  - On success: Redirects to slots page with welcome message.
  - On error: Redirects back with error message (e.g., "Invalid email or password").

### Logout
- **Endpoint:** `/auth/logout`
- **Methods:** `GET`
- **Description:** Log out the current user.
- **Example Request:**
  ```http
  GET /auth/logout
  ```
- **Example Response:**
  - Redirects to login page with logout message.

---

## Parking Slots

### List All Slots
- **Endpoint:** `/slots/` or `/slots/list`
- **Methods:** `GET`
- **Description:** List all parking slots with their availability.
- **Example Request:**
  ```http
  GET /slots/list
  Cookie: session=...
  ```
- **Example Response:**
  - Renders HTML page with all slots and their status (available/occupied).

### List Available Slots
- **Endpoint:** `/slots/available`
- **Methods:** `GET`
- **Description:** List only available parking slots.
- **Example Request:**
  ```http
  GET /slots/available
  Cookie: session=...
  ```
- **Example Response:**
  - Renders HTML page with only available slots.

---

## Reservations

### Create Reservation
- **Endpoint:** `/reservations/create`
- **Methods:** `POST`
- **Description:** Create a new reservation for a parking slot.
- **Request Body:**
  - `slot_id`: integer
- **Example Request (form-data):**
  ```http
  POST /reservations/create
  Content-Type: application/x-www-form-urlencoded
  Cookie: session=...

  slot_id=3
  ```
- **Example Response:**
  - On success: Redirects to `/reservations/<reservation_id>` with QR code.
  - On error: Redirects back with error message (e.g., "Slot already reserved").

### View Reservation
- **Endpoint:** `/reservations/<reservation_id>`
- **Methods:** `GET`
- **Description:** View details and QR code for a reservation.
- **Example Request:**
  ```http
  GET /reservations/42
  Cookie: session=...
  ```
- **Example Response:**
  - Renders HTML page with reservation details and QR code image.

### Checkout Reservation
- **Endpoint:** `/reservations/<reservation_id>/checkout`
- **Methods:** `POST`
- **Description:** Checkout and release the parking slot.
- **Example Request:**
  ```http
  POST /reservations/42/checkout
  Cookie: session=...
  ```
- **Example Response:**
  - On success: Redirects to slots page with success message.
  - On error: Redirects back with error message.

### My Reservations
- **Endpoint:** `/reservations`
- **Methods:** `GET`
- **Description:** List all reservations for the current user.
- **Example Request:**
  ```http
  GET /reservations
  Cookie: session=...
  ```
- **Example Response:**
  - Renders HTML page with a list of the user's reservations.

---


---

## JSON API Endpoints (for Services & Mobile App)

All endpoints below return JSON and are suitable for use by mobile apps or other services.

### Register (JSON)
- **Endpoint:** `/api/auth/register`
- **Methods:** `POST`
- **Authentication:** Not required
- **Request Example:**
  ```json
  {
    "email": "user@example.com",
    "password": "secret123",
    "password_confirm": "secret123"
  }
  ```
- **Response Example (Success):**
  ```json
  {"message": "Registration successful! Please log in."}
  ```
- **Response Example (Error):**
  ```json
  {"error": "Email already registered"}
  ```

### Login (JSON)
- **Endpoint:** `/api/auth/login`
- **Methods:** `POST`
- **Authentication:** Not required
- **Request Example:**
  ```json
  {
    "email": "user@example.com",
    "password": "secret123"
  }
  ```
- **Response Example (Success):**
  ```json
  {"message": "Welcome, user@example.com!", "user_id": 1, "email": "user@example.com"}
  ```
- **Response Example (Error):**
  ```json
  {"error": "Invalid email or password"}
  ```

### Logout (JSON)
- **Endpoint:** `/api/auth/logout`
- **Methods:** `POST`
- **Authentication:** Required
- **Response Example:**
  ```json
  {"message": "You have been logged out."}
  ```

### List All Slots
- **Endpoint:** `/api/slots`
- **Methods:** `GET`
- **Response Example:**
  ```json
  [
    {"id": 1, "slot_number": "A-01", "is_available": true},
    {"id": 2, "slot_number": "A-02", "is_available": false}
  ]
  ```

### List Available Slots
- **Endpoint:** `/api/slots/available`
- **Methods:** `GET`
- **Response Example:**
  ```json
  [
    {"id": 1, "slot_number": "A-01"}
  ]
  ```

### My Reservations
- **Endpoint:** `/api/reservations`
- **Methods:** `GET`
- **Response Example:**
  ```json
  [
    {"id": 42, "slot_number": "A-01", "reserved_at": "2026-01-31T12:00:00", "qr_code_data": "..."}
  ]
  ```

### Create Reservation
- **Endpoint:** `/api/reservations`
- **Methods:** `POST`
- **Request Example:**
  ```json
  {"slot_id": 1}
  ```
- **Response Example:**
  ```json
  {"message": "Reservation created", "reservation_id": 42}
  ```

### View Reservation
- **Endpoint:** `/api/reservations/<reservation_id>`
- **Methods:** `GET`
- **Response Example:**
  ```json
  {"id": 42, "slot_number": "A-01", "reserved_at": "2026-01-31T12:00:00", "qr_code_data": "..."}
  ```

### Checkout Reservation
- **Endpoint:** `/api/reservations/<reservation_id>/checkout`
- **Methods:** `POST`
- **Response Example:**
  ```json
  {"message": "Successfully checked out from slot A-01"}
  ```

---

## Notes
- All endpoints require authentication (login session or session cookie).
- JSON API endpoints (`/api/...`) return JSON responses suitable for programmatic access.
- HTML endpoints return rendered pages suitable for browser access.
- For QR code data, see the reservation details endpoint.

---

_Last updated: January 31, 2026_
