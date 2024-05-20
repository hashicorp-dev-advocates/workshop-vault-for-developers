FROM 3.9-eclipse-temurin-22 AS build
COPY pom.xml /app/
COPY src /app/src
RUN mvn -f /app/pom.xml clean package

FROM eclipse-temurin:22
EXPOSE 8081
COPY --from=build /app/target/*.jar /app/app.jar
ENTRYPOINT ["java", "-XX:+UseContainerSupport", "-Djava.security.egd=file:/dev/./urandom","-jar","/app/app.jar"]