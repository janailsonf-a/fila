# CI/CD

## CI — `.github/workflows/ci.yml`

Roda em push na `main` e em todo PR. Matrix nos 4 serviços:
instala PHP 8.3 + dependências, gera `APP_KEY` e roda `php artisan test`
(sqlite em memória). Sem isso verde, nada segue.

## Build & Push — `.github/workflows/build-push.yml`

Builda a imagem de cada serviço e empurra pro Azure Container Registry.
Login por **OIDC** (federated credential) — **nenhum segredo salvo no repo**,
só variáveis com IDs públicos.

### Pré-requisitos
1. Infra provisionada (`terraform apply`) → ACR existe.
2. OIDC configurado (abaixo).
3. Variáveis do repo definidas.

### Configurar OIDC (uma vez)

```sh
az login
az account set --subscription 57f83508-8fbe-4a30-8b2b-c601a4ea007c

ACR_NAME=<filaacrXXXXXX> RG=rg-fila REPO=janailsonf-a/fila \
  ./scripts/azure-oidc-setup.sh
```

O script cria App Registration + credenciais federadas (main + PRs) + permissão
`AcrPush`, e imprime as 4 variáveis pra colar em
**Settings → Secrets and variables → Actions → Variables**:

| Variável | Valor |
|----------|-------|
| `AZURE_CLIENT_ID` | appId da App Registration |
| `AZURE_TENANT_ID` | tenant da Students |
| `AZURE_SUBSCRIPTION_ID` | id da Students |
| `ACR_NAME` | nome do ACR (com sufixo) |

### Por que OIDC e não secret
Sem senha/token guardado no GitHub. O Actions troca um token de identidade
por um token da Azure na hora, com escopo mínimo (`AcrPush` só no ACR).
Nada vaza se o repo vazar.

## Próximo (Fase 5/6)
Deploy nos Azure Container Apps (a App Registration vai precisar também de
`Contributor` no `rg-fila`) e pipeline de CD staging→prod com aprovação manual.
