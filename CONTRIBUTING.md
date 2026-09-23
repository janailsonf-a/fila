# Contribuindo

Obrigado pelo interesse! Fluxo:

1. Crie uma branch a partir da `main` (`feat/...`, `fix/...`, `chore/...`).
2. Rode os testes do serviço afetado: `cd services/<serviço> && php artisan test`.
3. Suba a stack local com `docker compose up --build` e valide o fluxo.
4. Abra um Pull Request descrevendo a mudança.

CI (GitHub Actions) roda os testes dos 4 serviços em cada PR — precisa passar.
