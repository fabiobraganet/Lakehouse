# Etapa 1: Imagem intermediária para instalar o cliente PostgreSQL
FROM alpine:latest AS builder

RUN apk add --no-cache postgresql-client nmap-ncat

# Copia o script de espera pelo PostgreSQL
COPY wait-for-postgres.sh /opt/keycloak/wait-for-postgres.sh
RUN chmod +x /opt/keycloak/wait-for-postgres.sh

# Etapa 2: Imagem final do Keycloak
FROM quay.io/keycloak/keycloak:25.0.1

# Copia o cliente PostgreSQL e nmap-ncat da imagem intermediária
COPY --from=builder /usr/bin/psql /usr/local/bin/psql
COPY --from=builder /usr/bin/nc /usr/local/bin/nc

# Copia o script de espera pelo PostgreSQL
COPY --from=builder /opt/keycloak/wait-for-postgres.sh /opt/keycloak/wait-for-postgres.sh

# Adiciona o driver do PostgreSQL
RUN /opt/keycloak/bin/kc.sh build --db=postgres

ENTRYPOINT ["/opt/keycloak/wait-for-postgres.sh"]