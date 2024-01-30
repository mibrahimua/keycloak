FROM quay.io/keycloak/keycloak:latest as builder

# Enable health and metrics support
ENV KC_HEALTH_ENABLED=true
ENV KC_METRICS_ENABLED=true

# Configure a database vendor
ENV KC_DB=postgres

WORKDIR /opt/keycloak
# for demonstration purposes only, please make sure to use proper certificates in production instead
RUN keytool -genkeypair -storepass password -storetype PKCS12 -keyalg RSA -keysize 2048 -dname "CN=server" -alias server -ext "SAN:c=DNS:localhost,IP:127.0.0.1" -keystore conf/server.keystore
RUN /opt/keycloak/bin/kc.sh build

FROM quay.io/keycloak/keycloak:latest
COPY --from=builder /opt/keycloak/ /opt/keycloak/

# Add the provider JAR file to the providers directory
#ADD --chown=keycloak:keycloak / /opt/keycloak/providers/myprovider.jar


# change these values to point to a running postgres instance
ENV KC_DB=postgres
ENV KC_DB_URL=localhost:5432/keycloak
ENV KC_DB_USERNAME=postgres123
ENV KC_DB_PASSWORD=admin123
ENV KC_HOSTNAME=localhost
ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]


RUN /opt/keycloak/bin/kc.sh build