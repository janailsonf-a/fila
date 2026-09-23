# Infra — Terraform (Azure)

IaC da base do projeto Fila. Provisiona o essencial; o deploy dos serviços
(Container Apps + KEDA) vem na fase 5.

## O que cria

| Recurso | Nome |
|---------|------|
| Resource Group | `rg-fila` |
| Container Registry (ACR) | `filaacr<sufixo>` |
| MySQL Flexible Server + 3 bancos | `fila-mysql-<sufixo>` (orders, inventory, payment) |
| Key Vault + segredos | `fila-kv-<sufixo>` |
| Log Analytics | `fila-logs` |
| Container Apps Environment | `fila-cae` |
| Container Apps (com `deploy_apps=true`) | rabbitmq + orders + 4 workers |

## Pré-requisitos

- Terraform >= 1.5
- `az login` na assinatura **Azure for Students**
  ```sh
  az login
  az account set --subscription 57f83508-8fbe-4a30-8b2b-c601a4ea007c
  ```

## Uso

```sh
cd infra/terraform

export TF_VAR_mysql_admin_password='<senha-forte>'
export TF_VAR_rabbitmq_password='<senha-forte>'

terraform init
terraform plan
terraform apply          # onda 1: base (deploy_apps=false)
```

### Deploy em 2 ondas

Os Container Apps só sobem depois que as imagens existem no ACR:

```sh
# Onda 1 — base (cria ACR, MySQL, Key Vault, env)
terraform apply

# → rode o build-push (via GitHub Actions, após OIDC) para publicar as imagens
#   no ACR. Veja ../../docs/CICD.md

# Onda 2 — sobe os serviços
terraform apply -var deploy_apps=true
```

`terraform output orders_url` mostra a URL pública da API.

Ao terminar de testar, para não gastar crédito:

```sh
terraform destroy
```

## Custo estimado

~US$40–50/mês com tudo ligado (MySQL B1ms + Log Analytics + ACR Basic;
Container Apps escala a zero). `terraform destroy` quando não estiver usando.

## Segredos

Nunca commitar `terraform.tfvars` nem `*.tfstate` (contêm senhas). Já ignorados
no `.gitignore`. Backend remoto (state em Storage Account) entra na fase de CI/CD.
