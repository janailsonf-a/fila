# Fila

Plataforma de venda de ingressos construída como **microserviços event-driven**.
Projeto de estudo/portfólio focado em backend PHP (Laravel) + práticas de DevOps/Cloud.

O problema central que justifica a arquitetura: **reserva de assento com
concorrência** — dois compradores não podem levar o mesmo lugar (anti-overselling),
com reserva temporária (hold) que expira.

## Arquitetura (alvo)

```
[web Next.js] → [orders] ⇄ RabbitMQ ⇄ [inventory]
                   ↑                        ↑
              [payment]  [notification]  (futuras fases)
```

Comunicação entre serviços via **eventos** (RabbitMQ), padrão **saga com
compensação**. Cada serviço é dono do próprio banco (MySQL).

## Fase 1 (atual)

Dois serviços Laravel trocando eventos por RabbitMQ:

```
POST /orders (orders)
  → grava pedido PENDING
  → publica OrderCreated na fila "inventory"

inventory (worker) consome OrderCreated
  → tenta hold do assento com lock pessimista (lockForUpdate)
       assento livre    → publica SeatReserved  na fila "orders"
       ocupado          → publica SeatRejected (TAKEN)
       não existe       → publica SeatRejected (NOT_FOUND)

orders (worker) consome SeatReserved / SeatRejected
  → atualiza pedido para RESERVED ou REJECTED

GET /orders/{id} (orders) → estado final
```

### Serviços

| Serviço | Papel | Banco |
|---------|-------|-------|
| `orders` | API HTTP + worker; cria pedido, orquestra | `mysql-orders` |
| `inventory` | worker; hold de assento, anti-oversell | `mysql-inventory` |

Assentos semeados na sessão `show-1`: `A1`..`A5`.

## Rodar

```sh
docker compose up --build
```

Sobe: RabbitMQ (+ UI), 2x MySQL, orders (HTTP), orders-worker, inventory-worker.

- API orders: http://localhost:8080
- RabbitMQ UI: http://localhost:15672 (guest / guest)

## Testar

```sh
# 1. cria pedido de um assento livre → deve virar RESERVED
curl -s -X POST http://localhost:8080/api/orders \
  -H 'Content-Type: application/json' \
  -d '{"session_id":"show-1","seat_id":"A1","user_id":"u1"}'

# guarde o "id" retornado, então:
curl -s http://localhost:8080/api/orders/<ID>   # status: RESERVED

# 2. tenta o MESMO assento com outro pedido → deve virar REJECTED (TAKEN)
curl -s -X POST http://localhost:8080/api/orders \
  -H 'Content-Type: application/json' \
  -d '{"session_id":"show-1","seat_id":"A1","user_id":"u2"}'
# consulte esse novo id → status: REJECTED, reason: TAKEN
```

## Stack

- **Laravel 13 / PHP 8.3** — serviços
- **RabbitMQ** — mensageria (`vladimir-yuldashev/laravel-queue-rabbitmq`)
- **MySQL 8** — um banco por serviço
- **Docker / Docker Compose** — orquestração local

## Próximas fases

3. IaC (Terraform) na Azure · 4. CI (GitHub Actions + OIDC) ·
5. Deploy Azure Container Apps + KEDA · 6. CD staging→prod ·
7. Observability (OpenTelemetry + Grafana) · 8. Polish.
