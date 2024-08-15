#!/bin/bash

DOCKER_COMPOSE_FILE=docker-compose.yml

# Função para garantir que as permissões dos scripts estejam corretas
function set_permissions {
  echo "Definindo permissões para os scripts..."
  chmod +x ./docker/postgres/backup.sh
  chmod +x ./docker/keycloak/commands/create_from_json.sh
  chmod +x ./docker/keycloak/wait-for-postgres.sh
}

# Garantir que a rede produto_network exista
if ! docker network ls | grep -q "produto_network"; then
  echo "Criando a rede produto_network..."
  docker network create produto_network
else
  echo "Rede produto_network já existe."
fi

# Garantir que as permissões dos scripts estejam corretas
set_permissions

# Verifica se docker-compose está instalado
if ! [ -x "$(command -v docker-compose)" ]; then
  echo 'Erro: docker-compose não está instalado.' >&2
  exit 1
fi

# Parando todos os contêineres em execução
echo "Parando todos os contêineres em execução..."
docker-compose -f $DOCKER_COMPOSE_FILE down

# Construindo as imagens do Docker
echo "Construindo as imagens do Docker..."
docker-compose -f $DOCKER_COMPOSE_FILE build

# Subindo os contêineres do Docker
echo "Subindo os contêineres do Docker..."
docker-compose -f $DOCKER_COMPOSE_FILE up -d

# Exibir o status dos containers
echo "Status dos containers:"
docker-compose ps

# Função para configurar o realm no Keycloak
configure_realm() {
  # Espera o Keycloak estar disponível
  until $(curl --output /dev/null --silent --head --fail http://localhost:6003); do
    echo "Esperando pelo Keycloak..."
    sleep 5
  done

  # Configurando o realm
  echo "Configurando o realm..."
  ./docker/keycloak/commands/create_from_json.sh
}

# Configura o realm em background para não bloquear a execução
configure_realm &

# Exibindo os logs dos contêineres
echo "Exibindo os logs dos contêineres..."
docker-compose -f $DOCKER_COMPOSE_FILE logs -f
