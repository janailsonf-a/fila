FROM php:8.3-cli

RUN apt-get update && apt-get install -y \
        git unzip libzip-dev \
    && docker-php-ext-install pdo_mysql sockets bcmath zip \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /app
COPY . /app

RUN composer install --no-interaction --prefer-dist --no-dev --optimize-autoloader

CMD ["php", "artisan", "queue:work", "rabbitmq", "--queue=inventory"]
