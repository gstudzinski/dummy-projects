FROM openjdk:17.0-jdk-slim

RUN apt-get update \
    && apt-get install -y openssh-server \
    && mkdir -p /var/run/sshd

EXPOSE 22

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
COPY /target/aws-db-*.war /app/app.war

ENTRYPOINT ["docker-entrypoint.sh"]
HEALTHCHECK --interval=3s CMD curl --fail http://localhost:8080/db/api/health
