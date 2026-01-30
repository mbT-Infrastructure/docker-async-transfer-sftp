# async-transfer-sftp image

This image contains a file transfer service based on `rclone` and `cron`. It automatically transfers
files between a local directory and a remote SFTP server on a configured schedule.

The container supports both downloading and uploading. Note that the operation is a **move**,
meaning files are deleted from the source after successful transfer.

## Installation

1. Pull from [Docker Hub], download the package from [Releases] or build using `builder/build.sh`

## Usage

### Environment variables

- `CRON_SCHEDULE`
    - The time to start the download and upload as cron schedule.
- `LOG_LEVEL`
    - Set log level for rclone.
- `MAX_BANDWIDTH`
    - Limit the upload and download bandwidth, for example `10M` for 10 MB/s.
- `NUM_TRANSFERS`
    - Number of file transfers to run in parallel.
- `REMOTE_DOWNLOAD_DIR`
    - The directory on the remote SFTP server to download files from.
- `REMOTE_UPLOAD_DIR`
    - The directory on the remote SFTP server to upload files to.
- `SERVER_URL`
    - Server to download from and upload to, in the format `sftp://user@hostname[:port]`.
- `SERVER_KEY`
    - SSH key to use for authorization to the server.
- `SERVER_IDENTITY`
    - Public key of the server for host key checking.

### Volumes

- `/media/async-transfer/incoming`
    - Local directory where files downloaded from the remote server are stored.
- `/media/async-transfer/outgoing`
    - Local directory used as source for uploads to the remote server. Files placed here will be
      moved to the remote server.

## Development

To build and run the docker container for development execute:

```bash
docker compose --file docker-compose-dev.yaml up --build
```

[Docker Hub]: https://hub.docker.com/r/madebytimo/async-transfer-sftp
[Releases]: https://github.com/mbt-infrastructure/docker-async-transfer-sftp/releases
