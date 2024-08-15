FROM apache/airflow:2.9.3

# Defina o usuário padrão para "administrator"
USER root

# Instale dependências adicionais, se necessário
# RUN apt-get update && apt-get install -y <outros-pacotes-necessários>

# Alterne para o usuário airflow
USER airflow

# Adicione qualquer requisito Python adicional (opcional)
COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

# Configure as permissões para o usuário "administrator"
USER 50000:0

# Entrypoint padrão para o Airflow
ENTRYPOINT ["/entrypoint"]
