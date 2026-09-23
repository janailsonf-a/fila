.PHONY: up down logs test ps

up:            ## Sobe a stack completa (build)
	docker compose up -d --build

down:          ## Derruba a stack
	docker compose down

logs:          ## Segue os logs
	docker compose logs -f

ps:            ## Status dos containers
	docker compose ps

test:          ## Roda os testes dos serviços PHP
	@for s in orders inventory payment notification; do \
		echo "== $$s =="; (cd services/$$s && php artisan test); \
	done
