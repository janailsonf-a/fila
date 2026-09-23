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
terraform apply
```

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
