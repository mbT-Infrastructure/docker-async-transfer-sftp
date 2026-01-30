FROM madebytimo/cron

RUN apt update -qq && apt install -y -qq rclone \
    && rm -rf /var/lib/apt/lists/* \
    \
    && mkdir --parents /media/async-transfer/{incoming,outgoing} \
    && mkdir --parents /opt/async-transfer-sftp/templates

COPY files/async-transfer-env.sh /opt/async-transfer-sftp/templates/
COPY files/entrypoint.sh files/run-download.sh files/run-upload.sh /usr/local/bin/

ENV CRON_SCHEDULE="0 2 * * *"
ENV LOG_LEVEL="INFO"
ENV MAX_BANDWIDTH=0
ENV REMOTE_DOWNLOAD_DIR="async-transfer/outgoing"
ENV REMOTE_UPLOAD_DIR="async-transfer/incoming"
ENV SERVER_IDENTITY=""
ENV SERVER_KEY=""
ENV SERVER_URL=""

WORKDIR /
ENTRYPOINT [ "entrypoint.sh" ]
CMD [ "run-cron.sh" ]

LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.source=\
"https://github.com/mbt-infrastructure/docker-async-transfer-sftp"
