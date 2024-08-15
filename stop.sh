#!/bin/bash

echo "Parando os serviços..."
docker-compose down

echo "Removendo a rede..."
docker network rm produto_network
