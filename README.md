# Sweet Cafe API

A comprehensive RESTful API for cafe management with JWT authentication, order management, and menu systems.

## Features

**Complete Authentication System**
- JWT-based token authentication
- User registration and login
- Role-based access control (Customer & Admin)

**Menu Management**
- Categories with nested menu items
- Menu item CRUD operations
- Availability tracking
- Price management

**Order System**
- Create orders with multiple items
- Order status tracking (pending, completed, delivered, cancelled)
- Delivery information management
- Order history per user

**User Management**
- User profiles
- Order history
- Admin user management

**Security**
- JWT token authentication
- Password encryption with bcrypt
- Role-based authorization
- CORS enabled

## Tech Stack

- **Ruby** 3.x
- **Rails** 8.0.4
- **PostgreSQL** database
- **JWT** for authentication
- **bcrypt** for password hashing

## Quick Start

### Prerequisites

- Ruby 3.x installed
- PostgreSQL installed and running
- Bundler installed

### Installation

1. **Clone the repository**
```bash
cd h:\web\RoR\sweetcafe\sweetcafeAPI
```

2. **Install dependencies**
```powershell
bundle install
```

3. **Setup database**
```powershell
rails db:create
rails db:migrate
rails db:seed
```

4. **Start the server**
```powershell
rails server
```

The API will be available at `http://localhost:3000`

### Test Credentials

After running `db:seed`, you can use these accounts:

- **Admin**: `admin@sweetcafe.com` / `password123`
- **Customer 1**: `john@example.com` / `password123`
- **Customer 2**: `jane@example.com` / `password123`

## API Documentation

Full API documentation is available in [API_DOCUMENTATION.md](./API_DOCUMENTATION.md)

### Quick Example

**1. Sign up or Login**
```bash
POST http://localhost:3000/api/v1/auth/login
Content-Type: application/json

{
  "email": "john@example.com",
  "password": "password123"
}
```

Response includes a JWT token:
```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "user": {...}
}
```

**2. Use the token for authenticated requests**
```bash
GET http://localhost:3000/api/v1/menu_items
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...
```

## Project Structure

```
app/
├── controllers/
│   ├── application_controller.rb    # Base controller with authentication
│   └── api/v1/                      # API v1 controllers
│       ├── auth_controller.rb       # Authentication endpoints
│       ├── categories_controller.rb  # Category management
│       ├── menu_items_controller.rb # Menu item management
│       ├── orders_controller.rb     # Order management
│       └── users_controller.rb      # User management
├── models/
│   ├── user.rb                      # User model with authentication
│   ├── category.rb                  # Category model
│   ├── menu_item.rb                 # Menu item model
│   ├── order.rb                     # Order model
│   ├── order_item.rb                # Order item model
│   └── delivery.rb                  # Delivery model
lib/
└── json_web_token.rb                # JWT encoding/decoding utility
config/
├── routes.rb                        # API routes
└── initializers/
    └── cors.rb                      # CORS configuration
```

## API Endpoints Overview

### Authentication
- `POST /api/v1/auth/signup` - Register new user
- `POST /api/v1/auth/login` - Login user
- `GET /api/v1/auth/me` - Get current user
- `DELETE /api/v1/auth/logout` - Logout user

### Categories
- `GET /api/v1/categories` - List all categories
- `GET /api/v1/categories/:id` - Get category with menu items
- `POST /api/v1/categories` - Create category (Admin)
- `PATCH /api/v1/categories/:id` - Update category (Admin)
- `DELETE /api/v1/categories/:id` - Delete category (Admin)

### Menu Items
- `GET /api/v1/menu_items` - List all menu items (with filters)
- `GET /api/v1/menu_items/:id` - Get menu item details
- `POST /api/v1/menu_items` - Create menu item (Admin)
- `PATCH /api/v1/menu_items/:id` - Update menu item (Admin)
- `DELETE /api/v1/menu_items/:id` - Delete menu item (Admin)

### Orders
- `GET /api/v1/orders` - List user orders
- `GET /api/v1/orders/:id` - Get order details
- `POST /api/v1/orders` - Create new order
- `PATCH /api/v1/orders/:id` - Update order status
- `POST /api/v1/orders/:id/cancel` - Cancel order

### Users
- `GET /api/v1/users` - List all users (Admin)
- `GET /api/v1/users/:id` - Get user profile
- `PATCH /api/v1/users/:id` - Update user profile
- `DELETE /api/v1/users/:id` - Delete user (Admin)
- `GET /api/v1/users/:id/orders` - Get user's orders

## Development

### Run tests
```powershell
rails test
```

### Access Rails console
```powershell
rails console
```

### View all routes
```powershell
rails routes
```

### Database commands
```powershell
# Reset database
rails db:reset

# Run specific migration
rails db:migrate:up VERSION=20251117140000

# Rollback last migration
rails db:rollback
```

## Environment Variables

Create a `.env` file in the root directory (optional):

```env
SECRET_KEY_BASE=your_secret_key_here
DATABASE_URL=postgresql://localhost/sweetcafe_api_development
```

## Production Deployment

Before deploying to production:

1. Update CORS settings in `config/initializers/cors.rb` with specific origins
2. Set `SECRET_KEY_BASE` environment variable
3. Configure production database
4. Enable SSL/TLS
5. Set up token refresh mechanism
6. Implement rate limiting
7. Set up monitoring and logging

## Contributing

This is a proprietary project. Please contact the project maintainer for contribution guidelines.

## License

Proprietary and confidential.

## Support

For issues and questions, please contact the development team.
