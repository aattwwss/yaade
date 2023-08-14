FROM node:alpine AS node
WORKDIR /app
COPY client/package*.json ./
RUN npm install 
COPY client/ ./
RUN npm run build

FROM adoptopenjdk/openjdk11:jdk-11.0.11_9-debian-slim AS cache
WORKDIR /app
ENV GRADLE_USER_HOME /cache
COPY server/build.gradle.kts server/gradle.properties server/gradlew server/settings.gradle.kts ./
COPY server/gradle ./gradle
RUN ./gradlew --no-daemon build --stacktrace

FROM adoptopenjdk/openjdk11:jdk-11.0.11_9-debian-slim
WORKDIR /app
ENV GRADLE_USER_HOME /cache
COPY server .
COPY --from=cache /cache /cache
RUN rm -rf server/src/main/resources/webroot
COPY --from=node /app/dist src/main/resources/webroot
RUN ./gradlew clean assemble

EXPOSE 9339

CMD [ "java", "-jar", "./build/libs/yaade-server-1.0-SNAPSHOT.jar"]

