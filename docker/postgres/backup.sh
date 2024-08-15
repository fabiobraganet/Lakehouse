#!/bin/bash

BACKUP_DIR="/backup"
PGPASSWORD="administrator"
TIMESTAMP=$(date +"\%Y-\%m-\%d_\%H-\%M-\%S")

# Espera até que o PostgreSQL esteja pronto
until pg_isready -h serverdb -U administrator; do
  echo "Aguardando PostgreSQL ficar pronto..."
  sleep 2
done

# Realiza backup de todos os bancos de dados
for db in $(psql -h serverdb -U administrator -t -c "SELECT datname FROM pg_database WHERE datistemplate = false;")
do
  BACKUP_FILE="$BACKUP_DIR/${db}_$TIMESTAMP.sql"
  pg_dump -h serverdb -U administrator -d "$db" > "$BACKUP_FILE"
done

# Mantém apenas os últimos 10 backups do dia atual
find "$BACKUP_DIR" -type f -name "*$(date +\%Y-\%m-\%d)*.sql" | sort -r | tail -n +11 | xargs rm -f

# Mantém apenas o último backup de cada dia anterior
for file in $(find "$BACKUP_DIR" -type f -name "*.sql" | sort | grep -v $(date +\%Y-\%m-\%d)); do
  DAY=$(basename "$file" | cut -d'_' -f2)
  LAST_BACKUP=$(find "$BACKUP_DIR" -type f -name "*${DAY}_*.sql" | sort | tail -n 1)
  if [ "$file" != "$LAST_BACKUP" ]; then
    rm -f "$file"
  fi
done
