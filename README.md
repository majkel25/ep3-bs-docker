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

#### Manual testing

Dry-run (no push sent, no idempotency row written):

```bash
php tools/ssa_daily_booking_reminder.php --dry-run --force
php tools/ssa_daily_booking_reminder.php --dry-run --uid=123 --force
```

First live test must stay single-user only:

```bash
php tools/ssa_daily_booking_reminder.php --uid=123 --force
```

Do not enable broadcast/scheduled sending until the dry-run and `uid=123` live device test have passed.

#### Idempotency

The script writes a row to `ssa_push_notification_log` before sending. The unique key is:

```
(uid, rule_key, notification_date, booking_signature_hash)
```

`booking_signature_hash` is a SHA-256 of the user's sorted active bookings for the day (bookingId, reservationId, tableName, timeStart, timeEnd). This means:

- Repeated runs with the same booking state are silently skipped — no duplicate push is sent.
- If the user's booking set changes (e.g. Table 3 cancelled and Table 1 booked), the hash changes and a new reminder is permitted.

Rule key: `daily_booking_reminders_8am`.

#### DigitalOcean Scheduled Job

##### Recommended schedule

```
0 7,8 * * *
```

This fires at 07:00 UTC and 08:00 UTC every day:

| UTC time | UK season | UK local time | Result |
|----------|-----------|---------------|--------|
| 07:00 UTC | BST (Mar–Oct) | 08:00 BST | guard passes, send runs |
| 07:00 UTC | GMT (Oct–Mar) | 07:00 GMT | guard rejects, exits cleanly |
| 08:00 UTC | BST (Mar–Oct) | 09:00 BST | guard rejects, exits cleanly |
| 08:00 UTC | GMT (Oct–Mar) | 08:00 GMT | guard passes, send runs |

The script's internal Europe/London `hour === 08` guard is the source of truth. Idempotency prevents duplicate sends even if both runs somehow pass during a DST transition.

##### App Platform setup

Add a Scheduled Job component in the DigitalOcean App console:

| Field | Value |
|-------|-------|
| Name | `ssa-daily-booking-reminder` |
| Run command | `php app/tools/ssa_daily_booking_reminder.php` |
| Schedule | `0 7,8 * * *` |

> **Path note:** the path `app/tools/...` assumes the working directory is the backend repo root. Adjust if DigitalOcean mounts the build at a different path — confirm against your web service's working directory.

> **YAML note:** if configuring via `app.yaml`, use `kind: SCHEDULED` for scheduled jobs. Validate the spec with `doctl apps spec validate` before applying; DigitalOcean's App Platform spec evolves and the YAML format should be confirmed against the current documentation.

The job inherits all env vars from the App, so no extra secret configuration is needed beyond what is already set for the web service.

##### Verifying a run

- **App Platform logs**: filter by component `ssa-daily-booking-reminder`; each run records stdout, stderr, and exit code.
- **Script stdout**: a successful send produces a JSON summary with `"sent": true`.
- **Database**: query `ssa_push_notification_log` for recent rows with `rule_key = 'daily_booking_reminders_8am'`.

##### Quick disable options

1. **Pause or delete** the scheduled job component in the DigitalOcean App console and redeploy.
2. **Change the schedule** to a non-firing expression (e.g. `0 3 31 2 *`) and redeploy.
3. An optional env-var guard (`SSA_ENABLE_SCHEDULED_REMINDER`) could allow instant kill-switch via an env var without redeployment, but this is not yet implemented.

#### Notification preference note

iOS category preferences currently persist locally on-device only. Backend preference sync is still required before the backend can enforce `daily_booking_reminders` or other category keys for scheduled pushes.

## contribute

This repository is work in progress, please open a PR if you have improvements. The Dockerfile could definitely get optimized.