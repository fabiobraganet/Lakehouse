#!/bin/bash

# Verificar se o Python está instalado
if ! command -v python3 &> /dev/null; then
    echo "Python3 não encontrado. Instale o Python3 para continuar."
    exit 1
fi

# Caminho correto para o script Python
python3 ./docker/keycloak/commands/create_realms.py

if [ $? -eq 0 ]; then
    echo "Realms criados com sucesso."
else
    echo "Erro ao criar realms."
    exit 1
fi
