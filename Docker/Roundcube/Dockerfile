FROM roundcube/roundcubemail:1.6.11-apache

COPY ./config/tls.crt /usr/local/share/ca-certificates/keycloak.crt
RUN apt-get install -y ca-certificates \
 && update-ca-certificates \