# Multi-stage build for optimized production image
FROM node:18-alpine AS builder

WORKDIR /app

# Install dependencies
COPY package*.json ./
COPY packages ./packages
COPY extensions ./extensions
COPY themes ./themes
RUN npm install --legacy-peer-deps

# Build the application
COPY . .
RUN npm run build

# Production stage
FROM node:18-alpine

WORKDIR /app

# Install production dependencies only
COPY package*.json ./
RUN npm ci --only=production --legacy-peer-deps

# Copy built application from builder
COPY --from=builder /app/packages ./packages
COPY --from=builder /app/themes ./themes
COPY --from=builder /app/extensions ./extensions
COPY --from=builder /app/public ./public
COPY --from=builder /app/media ./media
COPY --from=builder /app/config ./config
COPY --from=builder /app/translations ./translations

# Create non-root user for security
RUN addgroup -g 1001 -S nodejs && adduser -S nodejs -u 1001
USER nodejs

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000', (r) => {if (r.statusCode !== 200) throw new Error(r.statusCode)})"

CMD ["npm", "run", "start"]