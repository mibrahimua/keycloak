FROM quay.io/keycloak/keycloak:latest as builder

# Enable health and metrics support
ENV KC_HEALTH_ENABLED=true
ENV KC_METRICS_ENABLED=true

# change these values to point to a running postgres instance
ENV KC_DB=postgres

WORKDIR /opt/keycloak

COPY providers/* /opt/keycloak/providers/
COPY themes/*   /opt/keycloak/themes/
COPY conf/quarkus.properties /opt/keycloak/conf/

# for demonstration purposes only, please make sure to use proper certificates in production instead
RUN keytool -genkeypair -storepass password -storetype PKCS12 -keyalg RSA -keysize 2048 -dname "CN=server" -alias server -ext "SAN:c=DNS:localhost,IP:127.0.0.1" -keystore conf/server.keystore
RUN /opt/keycloak/bin/kc.sh build

FROM quay.io/keycloak/keycloak:latest
COPY --from=builder /opt/keycloak/ /opt/keycloak/

ENV KC_DB=postgres
ENV KC_DB_URL=jdbc:postgresql://postgresuser:5432/keycloak
ENV KC_DB_USERNAME=postgres123
ENV KC_DB_PASSWORD=admin123
ENV KC_DB_URL_PROPERTIES="verifyServerCertificate=false&ssl=allow"

ENV KC_HOSTNAME=localhost

ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
