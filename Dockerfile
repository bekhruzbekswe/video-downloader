FROM node:22-bookworm-slim AS build
RUN apt-get update \
    && apt-get install -y --no-install-recommends python3 python-is-python3 \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY tsconfig.json ./
COPY bot.ts worker.ts queue.ts util.ts ./
RUN npm run build

FROM node:22-bookworm-slim
RUN apt-get update \
    && apt-get install -y --no-install-recommends ffmpeg python3 python-is-python3 ca-certificates \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /app
ENV NODE_ENV=production
COPY package*.json ./
RUN npm ci --omit=dev
COPY --from=build /app/dist ./dist
CMD ["node", "dist/bot.js"]
