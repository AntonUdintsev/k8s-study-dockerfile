# ---------- Build ----------
FROM gradle:8.7-jdk21-alpine AS builder

WORKDIR /app

COPY gradle/ gradle/
COPY build.gradle.kts settings.gradle.kts ./
COPY gradlew ./

RUN chmod +x gradlew
RUN ./gradlew dependencies --no-daemon || true

COPY src src

RUN ./gradlew clean build \
    -x test \
    -x ktlintKotlinScriptCheck \
    -x ktlintTestSourceSetCheck \
    -x ktlintMainSourceSetCheck \
    --no-daemon


# ---------- Runtime ----------
FROM eclipse-temurin:21-jre-alpine AS runtime

WORKDIR /app

RUN addgroup -S spring && adduser -S spring -G spring
USER spring:spring

COPY --chown=spring:spring --from=builder /app/build/libs/*.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
