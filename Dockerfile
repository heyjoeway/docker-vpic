FROM mcr.microsoft.com/mssql/server:2019-latest

ENV ACCEPT_EULA=Y

USER root

# Create backup directory
RUN mkdir -p /var/opt/mssql/backup

# Copy the vpic.bak file
COPY vpic.bak /var/opt/mssql/backup/vpic.bak

# Copy startup script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER mssql

EXPOSE 1433

ENTRYPOINT ["/entrypoint.sh"]
