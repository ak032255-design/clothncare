FROM node:20-slim AS frontend-build

WORKDIR /frontend
COPY ClothNCareFrontend/cloth-n-care-ui/package*.json ./
RUN npm install
COPY ClothNCareFrontend/cloth-n-care-ui/ ./
RUN npm run build

FROM eclipse-temurin:17-jre-alpine AS backend

RUN apk add --no-cache maven

WORKDIR /app
COPY ClothNCare/ClothNCare/pom.xml ./
COPY ClothNCare/ClothNCare/mvnw ./
COPY ClothNCare/ClothNCare/.mvn ./.mvn
COPY ClothNCare/ClothNCare/src ./src

COPY --from=frontend-build /frontend/dist /app/src/main/resources/static

RUN chmod +x ./mvnw
RUN ./mvnw clean package -DskipTests

FROM eclipse-temurin:17-jre-alpine

WORKDIR /app
COPY --from=backend /app/target/ClothNCare-0.0.1-SNAPSHOT.jar ./app.jar

COPY <<'EOF' /app/entrypoint.sh
#!/bin/sh
if echo "$DATABASE_URL" | grep -q "^postgres://"; then
  CREDS=$(echo "$DATABASE_URL" | sed 's|postgres://||' | sed 's|@.*||')
  USER=$(echo "$CREDS" | cut -d: -f1)
  PASS=$(echo "$CREDS" | cut -d: -f2-)
  HOST_DB=$(echo "$DATABASE_URL" | sed 's|postgres://[^@]*@||')
  
  export SPRING_DATASOURCE_URL="jdbc:postgresql://$HOST_DB"
  export SPRING_DATASOURCE_USERNAME="$USER"
  export SPRING_DATASOURCE_PASSWORD="$PASS"
  export DATABASE_DRIVER="org.postgresql.Driver"
  export DATABASE_DIALECT="org.hibernate.dialect.PostgreSQLDialect"
fi
exec java -jar app.jar
EOF
RUN chmod +x /app/entrypoint.sh

ENTRYPOINT ["/app/entrypoint.sh"]
