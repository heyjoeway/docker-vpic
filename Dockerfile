FROM mcr.microsoft.com/mssql/server:2019-latest

ENV ACCEPT_EULA=Y

USER root

# Install unzip
RUN apt-get update && apt-get install -y curl unzip && rm -rf /var/lib/apt/lists/*

# Copy startup script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Create backup directory
RUN mkdir -p /var/opt/mssql/backup

ENV VPIC_URL=https://vpic.nhtsa.dot.gov/api/vPICList_lite_2025_11.bak.zip

# Download, extract, and rename the vpic backup file
RUN set -e && \
    curl -L -f -o /tmp/vpic.zip "$VPIC_URL" && \
    unzip /tmp/vpic.zip -d /tmp && \
    rm /tmp/vpic.zip && \
    BAK_FILE=$(find /tmp -maxdepth 1 -name '*.bak' -type f | head -n 1) && \
    if [ -z "$BAK_FILE" ]; then echo "No .bak file found in archive"; exit 1; fi && \
    mv "$BAK_FILE" /var/opt/mssql/backup/vpic.bak


USER mssql

EXPOSE 1433

ENTRYPOINT ["/entrypoint.sh"]
