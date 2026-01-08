# Configuration

This directory contains configuration files for the EverShop application deployment.

## Configuration Files

### `default.json`
Default configuration used across all environments. Contains:
- Base URL: `https://oneshopcloud.com`
- Default shop settings (currency, language, timezone)
- Database connection settings (should be overridden in production)

### `production.json`
Production-specific configuration that overrides default settings when `NODE_ENV=production`.

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

## Environment-Specific Overrides

You can create additional environment-specific configuration files:
- `config/development.json`
- `config/staging.json`
- `config/test.json`

Or use environment variables to override specific settings (see [node-config documentation](https://github.com/node-config/node-config)).

## Security Note

**Important:** The default database credentials in `default.json` are placeholder values. In production, you should:
1. Use environment variables for sensitive data
2. Create a `config/local.json` file (gitignored) for local development
3. Use your deployment platform's secrets management for production credentials
