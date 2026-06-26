# Etapa de build
FROM eclipse-temurin:21-jdk AS build
WORKDIR /app

# Copiar arquivos necessários
COPY pom.xml .
COPY src ./src

# Compilar o projeto
RUN mvn package -DskipTests

# Etapa final
FROM eclipse-temurin:21-jre
WORKDIR /app

# Copiar o JAR gerado da etapa anterior
COPY --from=build /app/target/*.jar app.jar

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
