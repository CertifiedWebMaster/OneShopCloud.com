# Deployment Guide for OneShopCloud

This guide provides instructions for deploying the EverShop application to production with the base URL `https://oneshopcloud.com`.

## Prerequisites

Before deploying, ensure you have:
- A PostgreSQL database instance
- Node.js 18+ installed on your server
- Access to your domain's DNS settings
- SSL certificate for HTTPS (recommended: Let's Encrypt)

## Configuration

### 1. Base URL Configuration

The application is pre-configured with the base URL `https://oneshopcloud.com` in the following files:
- `config/default.json` - Default configuration
- `config/production.json` - Production override

### 2. Database Configuration

You have two options for configuring the database:

#### Option A: Environment Variables (Recommended)

1. Copy the environment variables template:
   ```bash
   cp .env.example .env
   ```

2. Edit `.env` with your actual database credentials:
   ```bash
   DB_HOST=your_database_host
   DB_PORT=5432
   DB_NAME=evershop
   DB_USER=your_db_user
   DB_PASSWORD=your_secure_password
   NODE_ENV=production
   ```

3. Copy the custom environment variables config:
   ```bash
   cp config/custom-environment-variables.json.example config/custom-environment-variables.json
   ```

#### Option B: Local Configuration File

Create a `config/local.json` file (gitignored) with your production settings:
```json
{
  "system": {
    "database": {
      "host": "your_database_host",
      "port": 5432,
      "database": "evershop",
      "user": "your_db_user",
      "password": "your_secure_password"
    }
  }
}
```

## Deployment Steps

### 1. Install Dependencies

```bash
npm install --production
```

### 2. Build the Application

```bash
npm run build
```

### 3. Database Setup

Run the database migrations:
```bash
npm run setup
```

This will create the necessary database tables and initial data.

### 4. Start the Application

For production:
```bash
NODE_ENV=production npm start
```

Or using a process manager like PM2:
```bash
pm2 start npm --name "evershop" -- start
pm2 save
pm2 startup
```

### 5. Configure Reverse Proxy (Nginx)

Create an Nginx configuration for your domain:

```nginx
server {
    listen 80;
    server_name oneshopcloud.com www.oneshopcloud.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name oneshopcloud.com www.oneshopcloud.com;

    ssl_certificate /path/to/your/certificate.crt;
    ssl_certificate_key /path/to/your/private.key;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }

    # Static assets
    location /assets/ {
        proxy_pass http://localhost:3000/assets/;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
```

Test and reload Nginx:
```bash
sudo nginx -t
sudo systemctl reload nginx
```

## Environment Variables Reference

| Variable | Description | Required | Default |
|----------|-------------|----------|---------|
| `NODE_ENV` | Environment mode | Yes | development |
| `DB_HOST` | Database host | Yes | localhost |
| `DB_PORT` | Database port | Yes | 5432 |
| `DB_NAME` | Database name | Yes | evershop |
| `DB_USER` | Database user | Yes | - |
| `DB_PASSWORD` | Database password | Yes | - |
| `SHOP_HOME_URL` | Override base URL | No | https://oneshopcloud.com |

## SSL/HTTPS Configuration

For production, you should use HTTPS. Use Let's Encrypt for free SSL certificates:

```bash
sudo apt-get install certbot python3-certbot-nginx
sudo certbot --nginx -d oneshopcloud.com -d www.oneshopcloud.com
```

## Monitoring and Logs

### Using PM2

View logs:
```bash
pm2 logs evershop
```

Monitor performance:
```bash
pm2 monit
```

### Application Logs

Logs are stored in the application's log directory. Configure log level in your environment:
```bash
export LOG_LEVEL=info  # debug, info, warn, error
```

## Health Checks

Verify the application is running:
```bash
curl https://oneshopcloud.com/health
```

## Troubleshooting

### Issue: Application can't connect to database
- Verify database credentials in `.env` or `config/local.json`
- Ensure PostgreSQL is running: `sudo systemctl status postgresql`
- Check database firewall rules

### Issue: Base URL not working
- Verify `shop.homeUrl` in config files
- Check Nginx proxy settings
- Ensure DNS points to your server

### Issue: Static assets not loading
- Check file permissions in `public/` directory
- Verify Nginx configuration for static file serving
- Clear browser cache

## Security Checklist

- [ ] Change all default passwords
- [ ] Enable SSL/HTTPS
- [ ] Set up firewall rules
- [ ] Use environment variables for secrets
- [ ] Enable database backups
- [ ] Keep Node.js and dependencies updated
- [ ] Configure rate limiting
- [ ] Set up monitoring and alerts

## Backup and Recovery

### Database Backup
```bash
pg_dump -U your_db_user evershop > backup_$(date +%Y%m%d).sql
```

### Media Files Backup
```bash
tar -czf media_backup_$(date +%Y%m%d).tar.gz media/
```

## Support

For issues and questions:
- GitHub Issues: https://github.com/CertifiedWebMaster/evershop-oneshopcloud/issues
- EverShop Documentation: https://evershop.io/docs
- Discord Community: https://discord.gg/GSzt7dt7RM
