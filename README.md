# sync-maccy-clipboard-service

Syncs Maccy’s `Storage.sqlite` to Google Drive on a schedule using `rclone` in a Docker container.

## Setup

1. Copy `.env.example` to `.env` and fill in values.
2. Ensure your rclone config exists at `RCLONE_CONFIG_DIR` (typically `~/.config/rclone/rclone.conf`) and has a remote named `gdrive`.
3. Start the service:

```sh
docker compose up -d
```

## Notes / Security

- Maccy’s `Storage.sqlite` can contain highly sensitive clipboard history; treat it like a secret.
- Keep `.env` locked down (recommended permissions: `chmod 600 .env`).
- Avoid sharing the output of `docker compose config`: it expands variables and will print secrets like `RCLONE_CONFIG_PASS`.
- Consider using an `rclone crypt` remote (or other client-side encryption) if you want the backup encrypted end-to-end.
- Consider pinning the Docker image by digest (supply-chain hardening) instead of only a tag.

## Logs

Daily logs are written under `./logs/`.
