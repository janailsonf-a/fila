# Deploy por VM (Azure) — docker-compose

Caminho de deploy que **funciona na Azure for Students**: uma VM Linux roda o
`docker-compose.yml` completo. Resolve os limites do Container Apps *express*
(sem TCP ingress) — aqui TCP é livre, é só Docker.

## O que cria
- Resource Group `rg-fila-vm`
- VNet + subnet + NSG (libera 22, 8080 API, 15672 RabbitMQ UI)
- IP público + NIC
- VM Ubuntu 22.04 (`Standard_B2as_v2`, 2 vCPU / 8 GB)
- Chave SSH gerada (`fila-vm.pem`, gitignored)

O `cloud-init` instala Docker, clona o repo e roda `docker compose up -d --build`.

## Uso
```sh
cd infra/vm
az login && az account set --subscription 57f83508-8fbe-4a30-8b2b-c601a4ea007c

terraform init
terraform apply
```

Saídas: `public_ip`, `ssh`, `api_url` (`http://IP:8080`), `rabbitmq_ui`.

> A stack leva ~2-3 min pós-boot pra subir (build das imagens na VM). Acompanhe:
> `ssh -i fila-vm.pem azureuser@IP` → `cd /opt/fila && docker compose ps`.

### Testar
```sh
curl -s -X POST http://IP:8080/api/orders \
  -H 'Content-Type: application/json' \
  -d '{"session_id":"show-1","seat_id":"A1","user_id":"u1"}'
```

## Custo / desligar
`Standard_B2as_v2` ~US$30/mês se ligada 24/7. Para economizar:
```sh
az vm deallocate -g rg-fila-vm -n fila-vm   # para (não cobra compute)
az vm start      -g rg-fila-vm -n fila-vm   # liga de novo
terraform destroy                           # remove tudo
```

## Segurança
`allowed_ssh_cidr` default é `*`. Restrinja ao seu IP:
`terraform apply -var allowed_ssh_cidr="SEU_IP/32"`.
