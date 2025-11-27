# API Testing Guide

This document provides example requests to test all API endpoints using curl or any HTTP client.

## Base URL
```
http://localhost:3000
```

## 1. Authentication Tests

### Sign Up
```bash
curl -X POST http://localhost:3000/api/v1/auth/signup \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "test@example.com",
    "phone": "5555555555",
    "password": "password123",
    "password_confirmation": "password123"
  }'
```

### Login (Save the token from response)
```bash
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "password": "password123"
  }'
```

**Expected Response:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "user": {
    "id": 2,
    "name": "John Doe",
    "email": "john@example.com",
    "phone": "5551234567",
    "role": "customer",
    "created_at": "2025-11-17T..."
  },
  "message": "Login successful"
}
```

### Get Current User
```bash
curl -X GET http://localhost:3000/api/v1/auth/me \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

## 2. Categories Tests

### List All Categories (No auth required)
```bash
curl -X GET http://localhost:3000/api/v1/categories
```

### Get Single Category with Menu Items
```bash
curl -X GET http://localhost:3000/api/v1/categories/1
```

### Create Category (Admin only)
```bash
curl -X POST http://localhost:3000/api/v1/categories \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ADMIN_TOKEN_HERE" \
  -d '{
    "category": {
      "name": "Smoothies",
      "description": "Fresh fruit smoothies"
    }
  }'
```

### Update Category (Admin only)
```bash
curl -X PATCH http://localhost:3000/api/v1/categories/1 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ADMIN_TOKEN_HERE" \
  -d '{
    "category": {
      "description": "Updated description"
    }
  }'
```

## 3. Menu Items Tests

### List All Menu Items (No auth required)
```bash
curl -X GET http://localhost:3000/api/v1/menu_items
```

### Filter Menu Items by Category
```bash
curl -X GET "http://localhost:3000/api/v1/menu_items?category_id=1"
```

### Filter by Availability
```bash
curl -X GET "http://localhost:3000/api/v1/menu_items?available=true"
```

### Get Single Menu Item
```bash
curl -X GET http://localhost:3000/api/v1/menu_items/1
```

### Create Menu Item (Admin only)
```bash
curl -X POST http://localhost:3000/api/v1/menu_items \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ADMIN_TOKEN_HERE" \
  -d '{
    "menu_item": {
      "name": "Mocha",
      "description": "Coffee with chocolate",
      "price": 5.25,
      "category_id": 1,
      "available": true,
      "image_url": "https://example.com/mocha.jpg"
    }
  }'
```

### Update Menu Item (Admin only)
```bash
curl -X PATCH http://localhost:3000/api/v1/menu_items/1 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ADMIN_TOKEN_HERE" \
  -d '{
    "menu_item": {
      "price": 3.75,
      "available": false
    }
  }'
```

## 4. Orders Tests

### List User Orders
```bash
curl -X GET http://localhost:3000/api/v1/orders \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

### Filter Orders by Status
```bash
curl -X GET "http://localhost:3000/api/v1/orders?status=pending" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

### Get Single Order
```bash
curl -X GET http://localhost:3000/api/v1/orders/1 \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

### Create Order with Delivery
```bash
curl -X POST http://localhost:3000/api/v1/orders \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -d '{
    "order": {
      "notes": "Please make it extra hot"
    },
    "order_items": [
      {
        "menu_item_id": 1,
        "quantity": 2
      },
      {
        "menu_item_id": 3,
        "quantity": 1
      }
    ],
    "delivery": {
      "address": "456 Oak Avenue",
      "city": "San Francisco",
      "postal_code": "94102",
      "phone": "5559998888",
      "delivery_notes": "Leave at door"
    }
  }'
```

### Update Order Status
```bash
curl -X PATCH http://localhost:3000/api/v1/orders/1 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -d '{
    "status": "completed"
  }'
```

### Cancel Order
```bash
curl -X POST http://localhost:3000/api/v1/orders/1/cancel \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

## 5. Users Tests

### List All Users (Admin only)
```bash
curl -X GET http://localhost:3000/api/v1/users \
  -H "Authorization: Bearer ADMIN_TOKEN_HERE"
```

### Get User Profile
```bash
curl -X GET http://localhost:3000/api/v1/users/2 \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

### Update User Profile
```bash
curl -X PATCH http://localhost:3000/api/v1/users/2 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -d '{
    "user": {
      "name": "John Updated",
      "phone": "5551112222"
    }
  }'
```

### Get User's Orders
```bash
curl -X GET http://localhost:3000/api/v1/users/2/orders \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

## PowerShell Examples

If using PowerShell, use this format:

### Login
```powershell
$response = Invoke-RestMethod -Uri "http://localhost:3000/api/v1/auth/login" `
  -Method Post `
  -ContentType "application/json" `
  -Body (@{
    email = "john@example.com"
    password = "password123"
  } | ConvertTo-Json)

$token = $response.token
Write-Host "Token: $token"
```

### Get Categories
```powershell
Invoke-RestMethod -Uri "http://localhost:3000/api/v1/categories" `
  -Method Get | ConvertTo-Json -Depth 5
```

### Create Order
```powershell
$headers = @{
  "Authorization" = "Bearer $token"
  "Content-Type" = "application/json"
}

$body = @{
  order = @{
    notes = "Extra hot please"
  }
  order_items = @(
    @{
      menu_item_id = 1
      quantity = 2
    },
    @{
      menu_item_id = 2
      quantity = 1
    }
  )
  delivery = @{
    address = "123 Main St"
    city = "New York"
    postal_code = "10001"
    phone = "5551234567"
    delivery_notes = "Ring doorbell"
  }
} | ConvertTo-Json -Depth 5

Invoke-RestMethod -Uri "http://localhost:3000/api/v1/orders" `
  -Method Post `
  -Headers $headers `
  -Body $body | ConvertTo-Json -Depth 5
```

## Test Admin Credentials

Use these credentials to test admin-only endpoints:
- Email: `admin@sweetcafe.com`
- Password: `password123`

## Test Customer Credentials

Use these credentials to test customer endpoints:
- Email: `john@example.com`
- Password: `password123`

or

- Email: `jane@example.com`
- Password: `password123`

## Expected HTTP Status Codes

- `200 OK` - Request succeeded
- `201 Created` - Resource created successfully
- `400 Bad Request` - Invalid request parameters
- `401 Unauthorized` - Authentication required or failed
- `403 Forbidden` - User lacks permission
- `404 Not Found` - Resource not found
- `422 Unprocessable Entity` - Validation errors

## Testing Workflow

1. **Login** as a customer to get a token
2. **List categories and menu items** (no auth needed)
3. **Create an order** with items and delivery info
4. **View your orders**
5. **Login as admin** to get admin token
6. **Create/update categories and menu items**
7. **View all users**

## Notes

- Replace `YOUR_TOKEN_HERE` with the actual JWT token from login response
- Replace `ADMIN_TOKEN_HERE` with the admin user's JWT token
- All timestamps are in ISO 8601 format
- Prices are returned as floating point numbers
- IDs are integers
