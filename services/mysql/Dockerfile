FROM mysql:8

# Cria os bancos extras (inventory, payment) e concede acesso ao usuário da app.
# O banco "orders" e o usuário vêm das variáveis MYSQL_DATABASE / MYSQL_USER.
COPY init.sql /docker-entrypoint-initdb.d/init.sql
