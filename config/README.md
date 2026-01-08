# Configuration

This directory contains configuration files for the EverShop application deployment.

## Configuration Files

### `default.json`
Default configuration used across all environments. Contains:
- Base URL: `https://oneshopcloud.com`
- Default shop settings (currency, language, timezone)
- Database connection placeholder values (MUST be overridden in production)

### `production.json`
Production-specific configuration that overrides default settings when `NODE_ENV=production`.

### `custom-environment-variables.json.example`
Template for mapping environment variables to configuration values. Copy to `custom-environment-variables.json` to use environment variables for sensitive configuration.

## Base URL Configuration

The application is configured to use `https://oneshopcloud.com` as the base URL. This is set via the `shop.homeUrl` configuration property.

The base URL is used throughout the application for:
- Building absolute URLs for pages
- Login/registration redirects
- Payment gateway callbacks (PayPal, Stripe)
- GraphQL resolvers
- Static asset URLs

## Usage

The Node.js `config` package automatically loads the appropriate configuration based on the `NODE_ENV` environment variable:
- Development: Uses `default.json`
- Production: Uses `default.json` merged with `production.json`

## Environment Variables (Recommended for Production)

For production deployments, use environment variables instead of hardcoding sensitive values:

1. Copy `.env.example` to `.env` in the root directory
2. Fill in your actual database credentials
3. Copy `config/custom-environment-variables.json.example` to `config/custom-environment-variables.json`

The `custom-environment-variables.json` file maps environment variables to configuration keys:

```json
{
  "system": {
    "database": {
      "host": "DB_HOST",
      "port": "DB_PORT",
      "database": "DB_NAME",
      "user": "DB_USER",
      "password": "DB_PASSWORD"
    }
  }
}
```

Then set your environment variables:
```bash
export DB_HOST=your_database_host
export DB_PORT=5432
export DB_NAME=evershop
export DB_USER=your_db_user
export DB_PASSWORD=your_secure_password
export NODE_ENV=production
```

## Environment-Specific Overrides

You can create additional environment-specific configuration files:
- `config/development.json`
- `config/staging.json`
- `config/test.json`

## Local Development

For local development, create a `config/local.json` file (gitignored) with your local settings:

```json
{
  "system": {
    "database": {
      "host": "localhost",
      "user": "your_local_user",
      "password": "your_local_password"
    }
  }
}
```

## Security Notes

**Important:** 
- Never commit real credentials to the repository
- Use environment variables or `config/local.json` (gitignored) for sensitive data
- The placeholder values in `default.json` MUST be replaced in production
- Review your deployment platform's secrets management documentation
- Consider using a secrets manager like AWS Secrets Manager, Azure Key Vault, or HashiCorp Vault
