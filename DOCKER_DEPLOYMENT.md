# OneShopCloud Docker Deployment Guide

## Prerequisites
- Docker Desktop (https://www.docker.com/products/docker-desktop) or Docker Engine
- Docker Compose (included with Docker Desktop)
- Git

## Quick Start

### 1. Clone and Setup
```bash
git clone https://github.com/CertifiedWebMaster/OneShopCloud.com.git
cd OneShopCloud.com
```

### 2. Configure Environment
```bash
# Copy the example environment file
cp .env.docker.example .env.docker

# Edit with your secure credentials
nano .env.docker
# Or use your preferred editor
```

Update these values:
- `DB_PASSWORD` - Strong random password
- `PGADMIN_PASSWORD` - Admin panel password
- `DB_USER` - Database username (default: postgres)
- `DB_NAME` - Database name (default: evershop)

### 3. Build and Start
```bash
# Build the Docker image
docker-compose build

# Start all services
docker-compose up -d

# View logs
docker-compose logs -f app
```

### 4. Access Your Application
- **App**: http://localhost:3000
- **pgAdmin**: http://localhost:5050
  - Email: admin@example.com
  - Password: (from .env.docker)

## Docker Commands

### Start Services
```bash
docker-compose up -d
```

### Stop Services
```bash
docker-compose down
```

### Restart Services
```bash
docker-compose restart
```

### View Logs
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f app
docker-compose logs -f database
```

### Remove Everything (including data)
```bash
docker-compose down -v
```

### Rebuild Image
```bash
docker-compose build --no-cache
docker-compose up -d
```

## Database Management

### Access PostgreSQL from Host
```bash
# Using psql if installed locally
psql -h localhost -U postgres -d evershop

# Using Docker
docker-compose exec database psql -U postgres -d evershop
```

### Backup Database
```bash
docker-compose exec database pg_dump -U postgres evershop > backup.sql
```

### Restore Database
```bash
cat backup.sql | docker-compose exec -T database psql -U postgres evershop
```

### View Database Logs
```bash
docker-compose logs database
```

## Production Deployment

### On a VPS/Server

```bash
# 1. Install Docker and Docker Compose
sudo apt-get update
sudo apt-get install docker.io docker-compose

# 2. Clone repository
git clone https://github.com/CertifiedWebMaster/OneShopCloud.com.git
cd OneShopCloud.com

# 3. Set up secure environment file
cp .env.docker.example .env.docker
# Edit with strong passwords - DO NOT use defaults!
nano .env.docker

# 4. Start services
docker-compose up -d

# 5. Verify
docker-compose ps
curl http://localhost:3000
```

### With Nginx Reverse Proxy

Create `nginx-compose.yml`:
```yaml
version: '3.8'

services:
  nginx:
    image: nginx:alpine
    container_name: oneshopcloud-nginx
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ./ssl:/etc/nginx/ssl:ro
    depends_on:
      - app
    networks:
      - oneshopcloud-network

networks:
  oneshopcloud-network:
    external: true
```

### Environment Variables for Production
```bash
# .env.docker (production)
NODE_ENV=production
DB_PASSWORD=SecurePassword123!@#
DB_USER=shopuser
DB_NAME=oneshopcloud
PGADMIN_PASSWORD=PgAdminPass456!@#

# Optional: Domain/URL configuration
SHOP_URL=https://yourdomain.com
```

## Troubleshooting

### Port Already in Use
```bash
# Change port in docker-compose.yml
ports:
  - "3001:3000"  # Use 3001 instead of 3000
```

### Database Connection Failed
```bash
# Check database status
docker-compose logs database

# Ensure database is healthy
docker-compose ps

# Restart database
docker-compose restart database
```

### Build Failures
```bash
# Clean build
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

### Out of Memory
```bash
# Increase Docker memory limit in Docker Desktop settings
# Or limit container memory in docker-compose.yml:
services:
  app:
    mem_limit: 2g
  database:
    mem_limit: 1g
```

## Monitoring

### Health Check Status
```bash
docker-compose ps
# Look for "(healthy)" or "(unhealthy)" status
```

### Resource Usage
```bash
docker stats
```

### Check Application Logs
```bash
docker-compose logs app | tail -50
```

## Security Best Practices

1. **Use Strong Passwords**
   - Never use default credentials in production
   - Use 16+ character passwords with mixed case, numbers, symbols

2. **Environment Variables**
   - Don't commit `.env.docker` to git
   - Add to `.gitignore` ✓ (already done)

3. **Database Access**
   - Only expose PostgreSQL port internally (no 5432:5432 in production)
   - Use pgAdmin only for development/maintenance

4. **Network**
   - Use Nginx reverse proxy for production
   - Enable HTTPS/SSL certificates
   - Restrict port access with firewall rules

5. **Regular Backups**
   ```bash
   # Automated daily backup script
   #!/bin/bash
   TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
   docker-compose exec -T database pg_dump -U postgres evershop > backup_$TIMESTAMP.sql
   ```

## Scaling & Performance

### Increase Replicas (if load balancer configured)
```yaml
services:
  app:
    deploy:
      replicas: 3
```

### Database Optimization
```bash
# Connect to database
docker-compose exec database psql -U postgres -d evershop

# View slow queries
SELECT query, calls, mean_time FROM pg_stat_statements 
ORDER BY mean_time DESC LIMIT 10;

# Create index on frequently queried columns
CREATE INDEX idx_orders_customer ON orders(customer_id);
```

## Additional Resources

- EverShop Documentation: https://evershop.io/docs
- Docker Documentation: https://docs.docker.com/
- PostgreSQL Documentation: https://www.postgresql.org/docs/
- pgAdmin: https://www.pgadmin.org/docs/

## Support

For issues, check:
1. Docker Compose logs: `docker-compose logs`
2. Database logs: `docker-compose logs database`
3. Application logs: `docker-compose logs app`
4. EverShop issues: https://github.com/evershopcommerce/evershop/issues
