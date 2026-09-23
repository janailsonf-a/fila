# Fila

[![CI](https://github.com/janailsonf-a/fila/actions/workflows/ci.yml/badge.svg)](https://github.com/janailsonf-a/fila/actions/workflows/ci.yml)
![Laravel](https://img.shields.io/badge/Laravel-13-FF2D20?logo=laravel&logoColor=white)
![PHP](https://img.shields.io/badge/PHP-8.3-777BB4?logo=php&logoColor=white)
![Terraform](https://img.shields.io/badge/IaC-Terraform-7B42BC?logo=terraform&logoColor=white)
![License](https://img.shields.io/badge/license-MIT-green)

Plataforma de venda de ingressos construída como **microserviços event-driven**.
Projeto de estudo/portfólio focado em backend PHP (Laravel) + práticas de DevOps/Cloud.

O problema central que justifica a arquitetura: **reserva de assento com
concorrência** — dois compradores não podem levar o mesmo lugar (anti-overselling),
com reserva temporária (hold), pagamento e **compensação** quando algo falha.

## Arquitetura

```
[orders] ⇄ RabbitMQ ⇄ [inventory]
   ⇅                      
[payment]   [notification]
```

Comunicação entre serviços via **eventos** (RabbitMQ). O `orders` é o
**orquestrador da saga**; cada serviço é dono do próprio banco.

## Saga (orquestração pelo orders)

```
POST /orders (orders) → pedido PENDING → OrderCreated → fila "inventory"

inventory consome OrderCreated → hold do assento (lockForUpdate, anti-oversell)
    livre    → SeatReserved  → fila "orders"
    ocupado  → SeatRejected (TAKEN)     → fila "orders"
    inexist. → SeatRejected (NOT_FOUND) → fila "orders"

orders consome SeatReserved → pedido RESERVED → ChargePayment → fila "payment"
orders consome SeatRejected → pedido REJECTED (fim)

payment consome ChargePayment → cobra (mock)
    ok    → PaymentConfirmed → fila "orders"
    falha → PaymentFailed    → fila "orders"

orders consome PaymentConfirmed → pedido CONFIRMED → OrderConfirmed → fila "notification"
orders consome PaymentFailed    → pedido PAYMENT_FAILED → ReleaseSeat → fila "inventory"   ← COMPENSAÇÃO

inventory consome ReleaseSeat → devolve o assento (free)
notification consome OrderConfirmed → registra a notificação (log)
```

Regra mock do pagamento: **falha se `user_id` começa com `fail`**, senão aprova —
permite exercitar o caminho feliz e a compensação.

### Serviços

| Serviço | Papel | Estado |
|---------|-------|--------|
| `orders` | API HTTP + worker; orquestra a saga | `mysql-orders` |
| `inventory` | worker; hold/liberação de assento, anti-oversell | `mysql-inventory` |
| `payment` | worker; cobrança (mock) | `mysql-payment` |
| `notification` | worker; notificação (log) | sqlite (stateless) |

Assentos semeados na sessão `show-1`: `A1`..`A5`.

Estados do pedido: `PENDING → RESERVED → CONFIRMED`, ou `REJECTED` (sem assento),
ou `PAYMENT_FAILED` (pagamento falhou, assento compensado).

## Rodar

```sh
docker compose up --build
```

- API orders: http://localhost:8080
- RabbitMQ UI: http://localhost:15672 (fila / fila)

## Testar

```sh
# CAMINHO FELIZ → CONFIRMED
curl -s -X POST http://localhost:8080/api/orders \
  -H 'Content-Type: application/json' \
  -d '{"session_id":"show-1","seat_id":"A1","user_id":"u1"}'
# consulte o id retornado → status vai a CONFIRMED
curl -s http://localhost:8080/api/orders/<ID>

# OVERSELLING → REJECTED / TAKEN (mesmo assento já vendido)
curl -s -X POST http://localhost:8080/api/orders \
  -H 'Content-Type: application/json' \
  -d '{"session_id":"show-1","seat_id":"A1","user_id":"u2"}'

# PAGAMENTO FALHA → PAYMENT_FAILED + assento liberado (compensação)
curl -s -X POST http://localhost:8080/api/orders \
  -H 'Content-Type: application/json' \
  -d '{"session_id":"show-1","seat_id":"A2","user_id":"failuser"}'
# esse pedido vira PAYMENT_FAILED; o assento A2 volta a "free" e pode ser vendido de novo
```

## Stack

- **Laravel 13 / PHP 8.3** — serviços
- **RabbitMQ** — mensageria (`vladimir-yuldashev/laravel-queue-rabbitmq`)
- **MySQL 8** — um banco por serviço com estado
- **Docker / Docker Compose** — orquestração local

## Deploy na Azure (IaC)

Toda a infra é Terraform em [`infra/terraform`](infra/terraform) e o CI/CD em
[`.github/workflows`](.github/workflows) (build das imagens → ACR via OIDC, sem
segredo salvo). Ver [`docs/CICD.md`](docs/CICD.md).

Estado do deploy:

- ✅ Base provisionada (ACR, Key Vault, Log Analytics, Container Apps Environment)
- ✅ Imagens buildadas e publicadas no ACR pelo GitHub Actions
- ✅ Definição dos Container Apps (rabbitmq + mysql + orders + 4 workers) com
  autoescala **KEDA** por fila do RabbitMQ — `terraform validate` OK

> **Nota (Azure for Students):** o deploy final dos Container Apps esbarra em
> limites da assinatura *Students*: o Container Apps Environment é do tipo
> *express*, que **não suporta TCP ingress** (necessário para RabbitMQ:5672 e
> MySQL:3306) nem pull do ACR por *managed identity*; e o **MySQL Flexible
> gerenciado** não tem capacidade nas regiões permitidas pela policy da conta.
> O IaC está correto e completo — em uma assinatura padrão (Pay-As-You-Go /
> empresarial) o `terraform apply -var deploy_apps=true` sobe o ambiente inteiro.
> Para desenvolvimento e demonstração, use o `docker compose` acima, que executa
> a stack completa localmente.

## Próximas fases

6. CD staging→prod · 7. Observability (OpenTelemetry + Grafana) · 8. Polish.
