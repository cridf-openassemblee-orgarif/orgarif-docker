FROM openjdk:17

COPY orgarif /opt/orgarif
WORKDIR /opt/orgarif

CMD ["java", \
    "-Dlogback.configurationFile=/opt/orgarif/logback.xml", \
    "-Dspring.profiles.active=prod", \
    "-jar", "/opt/orgarif/orgarif-server.jar"]