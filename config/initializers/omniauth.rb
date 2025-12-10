# frozen_string_literal: true

# Google OAuth Configuration for API-only Rails application
# We use a service-based approach with direct HTTP calls to Google APIs
# This avoids the session requirement that comes with OmniAuth middleware

# Configuration is handled via environment variables:
# - GOOGLE_CLIENT_ID
# - GOOGLE_CLIENT_SECRET
# - API_BASE_URL
