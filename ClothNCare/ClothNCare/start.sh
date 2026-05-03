#!/bin/bash

# Convert Render's DATABASE_URL (postgres://user:pass@host:port/db) to JDBC format
if [[ "$DATABASE_URL" == postgres://* ]]; then
  JDBC_URL=$(echo "$DATABASE_URL" | sed 's|postgres://|jdbc:postgresql://|')
  export DATABASE_URL="$JDBC_URL"
fi

exec java $JAVA_OPTS -jar target/ClothNCare-0.0.1-SNAPSHOT.jar
