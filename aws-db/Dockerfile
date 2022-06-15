FROM openjdk:17.0-jdk-slim

COPY /target/aws-db-*.war /app/app.war

CMD ["java", "-XX:MaxRAMPercentage=75", "-XX:+ShowCodeDetailsInExceptionMessages", "-jar", "/app/app.war"]
HEALTHCHECK --interval=3s CMD curl --fail http://localhost:8080/db/api/health
