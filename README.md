# ep3-bs on docker

based on lamp stack https://github.com/jcavat/docker-lamp

## setup ep3-bs

Clone this repository, cd into it, then:

1. get ep3-bs files `git submodule init & git submodule update`
2. copy .env.example to .env `cp .env.example .env`
3. (optional) and add your mail settings to `.env`
3. build container `docker-compose build`
4. run `docker-compose up`
5. Open web browser at [http://localhost:8001](http://localhost:8001)

### file structure

- `app` - ep3-bs repository as a git submodule
- `install` – customized config files that get copied over the original files
- `volumes` - persistent files mounted by docker, created at first run. all your important files, including the database, appear here.
- `.env.example` - example for runtime variables .env

### phpmyadmin

Enable phpmyadmin by disabling the comments in docker-compose.yml. 
Open phpmyadmin at [http://localhost:8000](http://localhost:8000)

Run mysql client:

- `docker-compose exec db mysql -u root -p` 

### SSA iOS APNs push configuration

The SSA API push sender reads APNs credentials from environment variables only. Do not hardcode Apple credentials in the repository.

Required variables:

- `APNS_TEAM_ID`
- `APNS_KEY_ID`
- `APNS_TOPIC`
- `APNS_DEFAULT_ENV` (`development` or `production`)
- `APNS_KEY_P8_BASE64` preferred, or `APNS_KEY_P8`

Optional debug/testing flag:

- `SSA_ENABLE_DEBUG_PUSH_ENDPOINT=true` enables the authenticated current-user-only debug push endpoint at `/api/ssa/v1/push-test-booking-reminder.php`.

The `.p8` private key can be supplied as raw text via `APNS_KEY_P8` or as base64 via `APNS_KEY_P8_BASE64`; base64 is preferred for hosted environments that do not handle multiline secrets reliably.

The push sender requires PHP cURL support for APNs HTTP/2 requests. The Docker image installs and enables the PHP cURL extension.

### SSA daily My Bookings reminder scheduled job

The Stage 4 daily reminder sender lives in the app submodule at `tools/ssa_daily_booking_reminder.php`.

It sends at most one combined push per linked user per day when that user has table bookings for the current Europe/London date. It uses APNs tokens from `ssa_push_tokens`, writes idempotency rows to `ssa_push_notification_log`, and never logs full APNs tokens or private keys.

Manual dry-run examples:

```bash
php tools/ssa_daily_booking_reminder.php --dry-run --force
php tools/ssa_daily_booking_reminder.php --dry-run --uid=123 --force
```

First live test must stay single-user only:

```bash
php tools/ssa_daily_booking_reminder.php --uid=123 --force
```

Do not enable broadcast/scheduled sending until the dry-run and `uid=123` live device test have passed.

The script has an internal Europe/London 08:00 guard. Use `--force` only for manual testing. For DigitalOcean Scheduled Jobs, use either:

- two UTC runs, `07:00 UTC` and `08:00 UTC`, letting the Europe/London guard choose the valid DST/non-DST run; or
- an hourly morning-window run, again relying on the Europe/London guard.

Idempotency key: `(uid, rule_key, notification_date)` with rule key `daily_booking_reminders_8am`, so repeated scheduled runs do not duplicate sends.

Notification preference note: the iOS category preferences currently persist locally on-device. Backend preference sync is still required before the backend can enforce `daily_booking_reminders` or the other category keys for scheduled/event pushes.

## contribute

This repository is work in progress, please open a PR if you have improvements. The Dockerfile could definitely get optimized.