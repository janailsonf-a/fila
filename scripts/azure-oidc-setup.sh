#!/usr/bin/env bash
# Configura login OIDC do GitHub Actions na Azure — SEM segredo salvo no repo.
# Cria App Registration + Service Principal, credenciais federadas (main + PRs)
# e dá permissão de push no ACR. Ao final, imprime as variáveis do repo.
#
# Pré-requisitos: az login (assinatura Students) + ACR já criado (terraform apply).
#
# Uso:
#   ACR_NAME=filaacrXXXXXX RG=rg-fila REPO=janailsonf-a/fila ./scripts/azure-oidc-setup.sh

set -euo pipefail

REPO="${REPO:-janailsonf-a/fila}"
RG="${RG:-rg-fila}"
APP_NAME="${APP_NAME:-gh-actions-fila}"
: "${ACR_NAME:?defina ACR_NAME (ex: ACR_NAME=filaacrXXXXXX)}"

SUBSCRIPTION_ID="$(az account show --query id -o tsv)"
TENANT_ID="$(az account show --query tenantId -o tsv)"
ACR_ID="$(az acr show --name "$ACR_NAME" --resource-group "$RG" --query id -o tsv)"

echo ">> App Registration ($APP_NAME)"
APP_ID="$(az ad app list --display-name "$APP_NAME" --query '[0].appId' -o tsv)"
if [ -z "$APP_ID" ]; then
  APP_ID="$(az ad app create --display-name "$APP_NAME" --query appId -o tsv)"
fi
echo "   appId=$APP_ID"

echo ">> Service Principal"
az ad sp show --id "$APP_ID" >/dev/null 2>&1 || az ad sp create --id "$APP_ID" >/dev/null

echo ">> Credenciais federadas (main + pull_request)"
create_fic () {
  local name="$1" subject="$2"
  az ad app federated-credential list --id "$APP_ID" --query "[?name=='$name']" -o tsv | grep -q . && return 0
  az ad app federated-credential create --id "$APP_ID" --parameters "{
    \"name\": \"$name\",
    \"issuer\": \"https://token.actions.githubusercontent.com\",
    \"subject\": \"$subject\",
    \"audiences\": [\"api://AzureADTokenExchange\"]
  }" >/dev/null
}
# Algumas contas do GitHub apresentam o subject OIDC com IDs numéricos
# (repo:owner@<ownerid>/repo@<repoid>:...). Criamos as duas variantes para
# funcionar em qualquer caso.
OWNER="${REPO%%/*}"
NAME="${REPO##*/}"
REPO_JSON="$(curl -s "https://api.github.com/repos/${REPO}")"
OWNER_ID="$(echo "$REPO_JSON" | python3 -c 'import sys,json;print(json.load(sys.stdin)["owner"]["id"])' 2>/dev/null || true)"
REPO_ID="$(echo "$REPO_JSON" | python3 -c 'import sys,json;print(json.load(sys.stdin)["id"])' 2>/dev/null || true)"

create_fic "fila-main" "repo:${REPO}:ref:refs/heads/main"
create_fic "fila-pr"   "repo:${REPO}:pull_request"
if [ -n "$OWNER_ID" ] && [ -n "$REPO_ID" ]; then
  create_fic "fila-main-id" "repo:${OWNER}@${OWNER_ID}/${NAME}@${REPO_ID}:ref:refs/heads/main"
  create_fic "fila-pr-id"   "repo:${OWNER}@${OWNER_ID}/${NAME}@${REPO_ID}:pull_request"
  # Jobs com `environment:` (usados no CD) apresentam subject de environment.
  create_fic "fila-env-staging"    "repo:${OWNER}@${OWNER_ID}/${NAME}@${REPO_ID}:environment:staging"
  create_fic "fila-env-production" "repo:${OWNER}@${OWNER_ID}/${NAME}@${REPO_ID}:environment:production"
fi

echo ">> Permissão AcrPush no ACR"
az role assignment create \
  --assignee "$APP_ID" \
  --role AcrPush \
  --scope "$ACR_ID" >/dev/null 2>&1 || echo "   (já existia)"

cat <<EOF

======================================================================
OIDC pronto. Configure estas VARIÁVEIS (não secrets) no repo GitHub
  Settings → Secrets and variables → Actions → Variables:

  AZURE_CLIENT_ID        = $APP_ID
  AZURE_TENANT_ID        = $TENANT_ID
  AZURE_SUBSCRIPTION_ID  = $SUBSCRIPTION_ID
  ACR_NAME               = $ACR_NAME

Ou via gh (se logado):
  gh variable set AZURE_CLIENT_ID       -R $REPO -b "$APP_ID"
  gh variable set AZURE_TENANT_ID       -R $REPO -b "$TENANT_ID"
  gh variable set AZURE_SUBSCRIPTION_ID -R $REPO -b "$SUBSCRIPTION_ID"
  gh variable set ACR_NAME              -R $REPO -b "$ACR_NAME"
======================================================================
EOF
