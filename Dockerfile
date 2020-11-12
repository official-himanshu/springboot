FROM openjdk:8-alpine
COPY Student-0.0.1-SNAPSHOT.jar .

ENTRYPOINT ["java","-jar","Student-0.0.1-SNAPSHOT.jar"]