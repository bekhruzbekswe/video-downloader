# video-downloader

Telegram bot that downloads videos (Instagram/YouTube/TikTok) via yt-dlp and sends them back,
with a Redis-backed download queue and a MongoDB cache for repeat links.

## Run it anywhere

The image is published at `bekhruzbekswe/video-downloader`. You only need `docker-compose.yml`
and a `.env` file on the target machine — no repo checkout, no build:

```bash
# copy docker-compose.yml from this repo to the target machine
echo "BOT_TOKEN=your-token-here" > .env
docker compose pull
docker compose up -d
```

That's it — Mongo and Redis run as bundled containers with no extra setup. Uploads are capped
at Telegram's standard 50MB per file.

## Building from source instead

```bash
cp .env.example .env
# edit .env and set BOT_TOKEN
docker compose up -d --build
```

## Bigger uploads (up to 2GB)

Requires a local Telegram Bot API server, which needs its own app credentials (separate from
your bot token) from https://my.telegram.org/apps.

```bash
# in .env, set:
#   TELEGRAM_API_ID=...
#   TELEGRAM_API_HASH=...
#   TELEGRAM_API_ROOT=http://telegram-bot-api:8081

docker compose --profile local-api up -d --build
```

## YouTube blocking downloads ("Sign in to confirm you're not a bot")

YouTube increasingly requires an authenticated session to extract most videos — this affects
any yt-dlp-based tool, not just this bot, and is not something a retry or a JS runtime fixes on
its own. The reliable workaround is passing yt-dlp real session cookies:

1. Log into YouTube in a real browser and export cookies with an extension like
   [Get cookies.txt LOCALLY](https://chromewebstore.google.com/detail/get-cookiestxt-locally/cclelndahbckbenkjhflpdbgdldlbecc)
2. Save the file as `cookies.txt` in the project root
3. Uncomment the `volumes:` line under the `worker` service in `docker-compose.yml`
4. `docker compose up -d`

Notes: cookies expire and need periodic re-export; use a secondary/throwaway Google account
rather than your main one, since automated bulk downloading through it carries some risk of
that account getting flagged by YouTube's abuse detection. Instagram/TikTok links aren't
affected by this and don't need cookies.

## Logs

```bash
docker compose logs -f bot worker
```
