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

## contribute

This repository is work in progress, please open a PR if you have improvements. The Dockerfile could definitely get optimized.