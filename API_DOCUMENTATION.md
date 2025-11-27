# Sweet Cafe API Documentation

A comprehensive RESTful API for a cafe management system with JWT authentication, built with Ruby on Rails 8.

## Features

- **JWT Authentication**: Secure token-based authentication
- **User Management**: Customer and admin role support
- **Menu Management**: Categories and menu items with filtering
- **Order Management**: Create, view, update, and cancel orders
- **Delivery Tracking**: Delivery information associated with orders
- **JSON Responses**: All endpoints return JSON formatted data
- **CORS Enabled**: Cross-origin requests supported

## Setup

1. Install dependencies:
```bash
bundle install
```

2. Setup database:
```bash
rails db:create
rails db:migrate
rails db:seed
```

3. Start the server:
```bash
rails server
```

The API will be available at `http://localhost:3000`

## API Endpoints

### Authentication

#### Sign Up
```
POST /api/v1/auth/signup
Content-Type: application/json

{
  "name": "John Doe",
  "email": "john@example.com",
  "phone": "1234567890",
  "password": "password123",
  "password_confirmation": "password123"
}

Response: 201 Created
{
  "token": "eyJhbGc...",
  "user": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "phone": "1234567890",
    "role": "customer",
    "created_at": "2025-11-17T..."
  },
  "message": "Account created successfully"
}
```

#### Login
```
POST /api/v1/auth/login
Content-Type: application/json

{
  "email": "john@example.com",
  "password": "password123"
}

Response: 200 OK
{
  "token": "eyJhbGc...",
  "user": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "phone": "1234567890",
    "role": "customer",
    "created_at": "2025-11-17T..."
  },
  "message": "Login successful"
}
```

#### Get Current User
```
GET /api/v1/auth/me
Authorization: Bearer {token}

Response: 200 OK
{
  "user": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "phone": "1234567890",
    "role": "customer",
    "created_at": "2025-11-17T..."
  }
}
```

#### Logout
```
DELETE /api/v1/auth/logout
Authorization: Bearer {token}

Response: 200 OK
{
  "message": "Logged out successfully"
}
```

### Categories

#### List All Categories
```
GET /api/v1/categories

Response: 200 OK
{
  "categories": [
    {
      "id": 1,
      "name": "Coffee",
      "description": "Hot and cold coffee drinks",
      "menu_items_count": 5,
      "created_at": "2025-11-17T...",
      "updated_at": "2025-11-17T..."
    }
  ]
}
```

#### Get Category
```
GET /api/v1/categories/:id

Response: 200 OK
{
  "category": {
    "id": 1,
    "name": "Coffee",
    "description": "Hot and cold coffee drinks",
    "menu_items": [
      {
        "id": 1,
        "name": "Espresso",
        "description": "Strong coffee",
        "price": 3.50,
        "available": true
      }
    ],
    "created_at": "2025-11-17T...",
    "updated_at": "2025-11-17T..."
  }
}
```

#### Create Category (Admin only)
```
POST /api/v1/categories
Authorization: Bearer {token}
Content-Type: application/json

{
  "category": {
    "name": "Pastries",
    "description": "Fresh baked goods"
  }
}

Response: 201 Created
{
  "category": {...},
  "message": "Category created successfully"
}
```

#### Update Category (Admin only)
```
PATCH /api/v1/categories/:id
Authorization: Bearer {token}
Content-Type: application/json

{
  "category": {
    "name": "Updated Name",
    "description": "Updated description"
  }
}

Response: 200 OK
{
  "category": {...},
  "message": "Category updated successfully"
}
```

#### Delete Category (Admin only)
```
DELETE /api/v1/categories/:id
Authorization: Bearer {token}

Response: 200 OK
{
  "message": "Category deleted successfully"
}
```

### Menu Items

#### List All Menu Items
```
GET /api/v1/menu_items
Optional Query Parameters:
  - category_id: Filter by category
  - available: Filter by availability (true/false)

Response: 200 OK
{
  "menu_items": [
    {
      "id": 1,
      "name": "Espresso",
      "description": "Strong coffee shot",
      "price": 3.50,
      "available": true,
      "image_url": "https://...",
      "category": {
        "id": 1,
        "name": "Coffee"
      }
    }
  ]
}
```

#### Get Menu Item
```
GET /api/v1/menu_items/:id

Response: 200 OK
{
  "menu_item": {
    "id": 1,
    "name": "Espresso",
    "description": "Strong coffee shot",
    "price": 3.50,
    "available": true,
    "image_url": "https://...",
    "category": {
      "id": 1,
      "name": "Coffee"
    },
    "created_at": "2025-11-17T...",
    "updated_at": "2025-11-17T..."
  }
}
```

#### Create Menu Item (Admin only)
```
POST /api/v1/menu_items
Authorization: Bearer {token}
Content-Type: application/json

{
  "menu_item": {
    "name": "Cappuccino",
    "description": "Espresso with steamed milk",
    "price": 4.50,
    "category_id": 1,
    "available": true,
    "image_url": "https://..."
  }
}

Response: 201 Created
{
  "menu_item": {...},
  "message": "Menu item created successfully"
}
```

#### Update Menu Item (Admin only)
```
PATCH /api/v1/menu_items/:id
Authorization: Bearer {token}
Content-Type: application/json

{
  "menu_item": {
    "price": 4.75,
    "available": false
  }
}

Response: 200 OK
{
  "menu_item": {...},
  "message": "Menu item updated successfully"
}
```

#### Delete Menu Item (Admin only)
```
DELETE /api/v1/menu_items/:id
Authorization: Bearer {token}

Response: 200 OK
{
  "message": "Menu item deleted successfully"
}
```

### Orders

#### List User Orders
```
GET /api/v1/orders
Authorization: Bearer {token}
Optional Query Parameters:
  - status: Filter by order status (pending/completed/delivered/cancelled)

Response: 200 OK
{
  "orders": [
    {
      "id": 1,
      "status": "pending",
      "total_amount": 15.50,
      "notes": "No sugar",
      "created_at": "2025-11-17T..."
    }
  ]
}
```

#### Get Order
```
GET /api/v1/orders/:id
Authorization: Bearer {token}

Response: 200 OK
{
  "order": {
    "id": 1,
    "status": "pending",
    "total_amount": 15.50,
    "notes": "No sugar",
    "order_items": [
      {
        "id": 1,
        "menu_item": {
          "id": 1,
          "name": "Espresso",
          "description": "Strong coffee"
        },
        "quantity": 2,
        "price": 3.50,
        "subtotal": 7.00
      }
    ],
    "delivery": {
      "id": 1,
      "address": "123 Main St",
      "city": "New York",
      "postal_code": "10001",
      "phone": "1234567890",
      "delivery_notes": "Ring doorbell",
      "delivery_status": "pending",
      "delivered_at": null
    },
    "created_at": "2025-11-17T...",
    "updated_at": "2025-11-17T..."
  }
}
```

#### Create Order
```
POST /api/v1/orders
Authorization: Bearer {token}
Content-Type: application/json

{
  "order": {
    "notes": "Extra hot"
  },
  "order_items": [
    {
      "menu_item_id": 1,
      "quantity": 2
    },
    {
      "menu_item_id": 2,
      "quantity": 1
    }
  ],
  "delivery": {
    "address": "123 Main St",
    "city": "New York",
    "postal_code": "10001",
    "phone": "1234567890",
    "delivery_notes": "Ring doorbell"
  }
}

Response: 201 Created
{
  "order": {...},
  "message": "Order created successfully"
}
```

#### Update Order Status
```
PATCH /api/v1/orders/:id
Authorization: Bearer {token}
Content-Type: application/json

{
  "status": "completed"
}

Response: 200 OK
{
  "order": {...},
  "message": "Order updated successfully"
}
```

#### Cancel Order
```
POST /api/v1/orders/:id/cancel
Authorization: Bearer {token}

Response: 200 OK
{
  "order": {...},
  "message": "Order cancelled successfully"
}
```

### Users

#### List All Users (Admin only)
```
GET /api/v1/users
Authorization: Bearer {token}

Response: 200 OK
{
  "users": [
    {
      "id": 1,
      "name": "John Doe",
      "email": "john@example.com",
      "phone": "1234567890",
      "role": "customer"
    }
  ]
}
```

#### Get User Profile
```
GET /api/v1/users/:id
Authorization: Bearer {token}

Response: 200 OK
{
  "user": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "phone": "1234567890",
    "role": "customer",
    "orders_count": 5,
    "created_at": "2025-11-17T...",
    "updated_at": "2025-11-17T..."
  }
}
```

#### Update User Profile
```
PATCH /api/v1/users/:id
Authorization: Bearer {token}
Content-Type: application/json

{
  "user": {
    "name": "John Updated",
    "phone": "9876543210"
  }
}

Response: 200 OK
{
  "user": {...},
  "message": "Profile updated successfully"
}
```

#### Get User Orders
```
GET /api/v1/users/:id/orders
Authorization: Bearer {token}

Response: 200 OK
{
  "orders": [
    {
      "id": 1,
      "status": "pending",
      "total_amount": 15.50,
      "items_count": 3,
      "created_at": "2025-11-17T..."
    }
  ]
}
```

#### Delete User (Admin only)
```
DELETE /api/v1/users/:id
Authorization: Bearer {token}

Response: 200 OK
{
  "message": "User deleted successfully"
}
```

## Authentication

All authenticated endpoints require a JWT token in the Authorization header:

```
Authorization: Bearer {your_jwt_token}
```

Tokens are obtained from the login or signup endpoints and should be stored securely on the client side.

## Error Responses

The API returns standard HTTP status codes:

- `200 OK`: Request succeeded
- `201 Created`: Resource created successfully
- `400 Bad Request`: Invalid request parameters
- `401 Unauthorized`: Authentication required or failed
- `403 Forbidden`: User lacks permission
- `404 Not Found`: Resource not found
- `422 Unprocessable Entity`: Validation errors

Error response format:
```json
{
  "errors": ["Error message 1", "Error message 2"]
}
```

## User Roles

- **customer**: Can view menu, create orders, manage their own profile
- **admin**: Full access to all resources including user management, menu management

## Database Schema

### Users
- id, name, email, phone, password_digest, role, timestamps

### Categories
- id, name, description, timestamps

### Menu Items
- id, name, description, price, category_id, available, image_url, size, timestamps

### Orders
- id, user_id, status, total_amount, notes, timestamps

### Order Items
- id, order_id, menu_item_id, quantity, price, subtotal, timestamps

### Deliveries
- id, order_id, address, city, postal_code, phone, delivery_notes, delivery_status, delivered_at, timestamps

## Development

Run tests:
```bash
rails test
```

Run the console:
```bash
rails console
```

Check routes:
```bash
rails routes
```

## Production Considerations

1. Update CORS configuration in `config/initializers/cors.rb` to only allow specific origins
2. Set `SECRET_KEY_BASE` environment variable
3. Configure production database in `config/database.yml`
4. Enable SSL for secure token transmission
5. Implement token refresh mechanism
6. Add rate limiting
7. Implement proper logging and monitoring

## License

This project is proprietary and confidential.
