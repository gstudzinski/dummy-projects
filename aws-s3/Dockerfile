FROM openjdk:17.0-jdk-slim

EXPOSE 22

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
COPY /target/aws-s3-*.war /app/app.war

ENTRYPOINT ["docker-entrypoint.sh"]
HEALTHCHECK --interval=3s CMD curl --fail http://localhost:8081/db/api/health
