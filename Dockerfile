# --------------------------------------------------
# Base
# --------------------------------------------------
FROM node:20-alpine3.19 AS base

# 1. Install system dependencies
RUN apk add --no-cache libc6-compat

# 2. Set working directory
WORKDIR /app

# --------------------------------------------------
# Dependencies
# --------------------------------------------------
FROM base AS deps

# 1. Copy package manager files
COPY package.json yarn.lock* pnpm-lock.yaml* .npmrc* ./

# 2. Install dependencies (pick yarn/npm/pnpm automatically)
RUN --mount=type=cache,id=yarn,sharing=locked,target=/usr/local/share/.cache/yarn \
	if [ -f yarn.lock ]; then yarn install --frozen-lockfile; \
	elif [ -f package-lock.json ]; then npm ci; \
	elif [ -f pnpm-lock.yaml ]; then corepack enable pnpm && pnpm install; \
	else echo "Lockfile not found." && exit 1; \
	fi


# --------------------------------------------------
# Builder
# --------------------------------------------------
FROM base AS builder

# 1. Copy dependencies
COPY --from=deps /app/node_modules ./node_modules
COPY --from=deps /app/package.json ./package.json
COPY --from=deps /app/yarn.lock ./yarn.lock

# 2. Copy source code
COPY . .

# 3. Build Next.js app
RUN yarn build


# --------------------------------------------------
# Runner (common base for prod/dev)
# --------------------------------------------------
FROM base AS runner

# 1. Environment defaults (overridable)
ENV APP_SERVER_HOST="0.0.0.0" \
	APP_SERVER_PORT=3000 \
	APP_SERVER_PROTOCOL="http" \
	APP_SERVER_NAME="nextjs.local"

# --------------------------------------------------
# Production runner
# --------------------------------------------------
FROM runner AS runner-prod

# 1. Set production env
ENV NODE_ENV=production \
	NEXT_TELEMETRY_DISABLED=1

# 2. Create non-root user
RUN addgroup -g 1001 -S nodejs && adduser -S nextjs -u 1001

# 3. Copy production build artifacts
COPY --from=builder /app/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

# 4. Switch to non-root user
USER nextjs

# 5. Expose port
EXPOSE ${APP_SERVER_PORT}

# 6. Start Next.js server
CMD HOSTNAME=${APP_SERVER_HOST} PORT=${APP_SERVER_PORT} node server.js


# --------------------------------------------------
# Development runner
# --------------------------------------------------
FROM runner AS runner-dev

# 1. Set development env
ENV NODE_ENV=development \
		NEXT_TELEMETRY_DISABLED=1

# 2. Copy source code
COPY . .

# 3. Copy node_modules from deps (needed for next binary)
COPY --from=deps /app/node_modules ./node_modules

# 4. Expose port
EXPOSE ${APP_SERVER_PORT}

# 5. Start Next.js in development mode (Turbopack enabled)
CMD ["sh", "-c", "yarn dev --turbopack --port ${APP_SERVER_PORT} --hostname ${APP_SERVER_HOST}"]