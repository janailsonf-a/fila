-- Bancos por serviço (orders já é criado via MYSQL_DATABASE).
CREATE DATABASE IF NOT EXISTS inventory;
CREATE DATABASE IF NOT EXISTS payment;

-- Acesso do usuário da aplicação (criado via MYSQL_USER) aos bancos extras.
GRANT ALL PRIVILEGES ON inventory.* TO 'fila_admin'@'%';
GRANT ALL PRIVILEGES ON payment.* TO 'fila_admin'@'%';
FLUSH PRIVILEGES;
