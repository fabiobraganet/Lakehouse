import json
import requests

# Configurações
KEYCLOAK_URL = "http://localhost:6003"
ADMIN_USER = "administrator"
ADMIN_PASSWORD = "administrator"
CLIENT_ID = "admin-cli"
REALM_JSON_FILE = "./docker/keycloak/commands/00-realm-export.json"

def get_access_token():
    token_url = f"{KEYCLOAK_URL}/realms/master/protocol/openid-connect/token"
    payload = {
        "client_id": CLIENT_ID,
        "username": ADMIN_USER,
        "password": ADMIN_PASSWORD,
        "grant_type": "password"
    }
    response = requests.post(token_url, data=payload)
    response.raise_for_status()
    return response.json()['access_token']

def realm_exists(realm_name, token):
    url = f"{KEYCLOAK_URL}/admin/realms/{realm_name}"
    headers = {"Authorization": f"Bearer {token}"}
    response = requests.get(url, headers=headers)
    return response.status_code == 200

def create_realm(realm_data, token):
    url = f"{KEYCLOAK_URL}/admin/realms"
    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json"
    }
    # Converta o JSON para uma string para garantir que está correto
    realm_data_json = json.dumps(realm_data)
    print(f"Enviando JSON para o Keycloak: {realm_data_json}")  # Linha para debug

    response = requests.post(url, headers=headers, data=realm_data_json)
    if response.status_code not in [201, 204]:
        raise Exception(f"Erro ao criar realm: {response.text}")

def main():
    token = get_access_token()
    
    with open(REALM_JSON_FILE, 'r') as file:
        data = json.load(file)
        for realm in data['realms']:
            realm_name = realm.get('realm')
            if realm_exists(realm_name, token):
                print(f"Realm {realm_name} já existe. Pulando...")
            else:
                create_realm(realm, token)
                print(f"Realm {realm_name} criado com sucesso.")

if __name__ == "__main__":
    main()
