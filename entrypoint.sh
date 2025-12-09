#!/bin/bash

# Start SQL Server in the background
/opt/mssql/bin/sqlservr &

# Wait for SQL Server to be ready with proper health check
echo "Waiting for SQL Server to start..."
RETRIES=60
until /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "$MSSQL_SA_PASSWORD" -C -Q "SELECT 1" > /dev/null 2>&1; do
    RETRIES=$((RETRIES - 1))
    if [ $RETRIES -eq 0 ]; then
        echo "SQL Server failed to start in time"
        exit 1
    fi
    echo "Waiting for SQL Server... ($RETRIES attempts remaining)"
    sleep 1
done
echo "SQL Server is ready"

# Check if database already exists
DB_EXISTS=$(/opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "$MSSQL_SA_PASSWORD" -C -Q "SELECT COUNT(*) FROM sys.databases WHERE name = 'vpic'" -h -1 2>/dev/null | tr -d ' ')

if [ "$DB_EXISTS" != "1" ]; then
    echo "Restoring vpic database from backup..."
    
    # Get logical file names from the backup
    /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "$MSSQL_SA_PASSWORD" -C -Q "
    RESTORE DATABASE vPICList_Lite FROM DISK = N'/var/opt/mssql/backup/vpic.bak'
    WITH MOVE N'vPICList_Lite' TO N'/var/opt/mssql/data/vPICList_Lite.mdf',
        MOVE N'vPICList_Lite_log' TO N'/var/opt/mssql/data/vPICList_Lite_log.ldf',
        REPLACE,
        RECOVERY;
    "
    
    if [ $? -eq 0 ]; then
        echo "Database restored successfully!"
    else
        echo "Database restore failed. Attempting with file list discovery..."
        /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "$MSSQL_SA_PASSWORD" -C -Q "RESTORE FILELISTONLY FROM DISK = '/var/opt/mssql/backup/vpic.bak'"
    fi
else
    echo "Database vpic already exists, skipping restore."
fi

# Keep the container running
wait
