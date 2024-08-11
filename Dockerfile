ARG TAG=2022-latest
FROM mcr.microsoft.com/mssql/server:${TAG}

ENV MSSQL_DBNAME=master \
    MSSQL_SA_PASSWORD=YourStrongPassword123! \
    ACCEPT_EULA=Y

# Switch to root to install required packages
USER root

# For health check
RUN apt-get update && apt-get install -y netcat && rm -rf /var/lib/apt/lists/*

CMD /opt/mssql/bin/sqlservr & \
    until nc -z localhost 1433; do echo waiting for sqlservr; sleep 1; done && \
    if [ "$MSSQL_DBNAME" != "master" ]; then \
        until /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P $MSSQL_SA_PASSWORD -C -Q "CREATE DATABASE $MSSQL_DBNAME"; do \
                echo retry && sleep 1; \
            done && \
            echo "Database $MSSQL_DBNAME created."; \
    else \
        echo "Using default database. No new database created."; \
    fi && \
    tail -f /dev/null