FROM php:8.2-cli

    RUN apt-get update && apt-get install -y git curl libpng-dev libonig-dev libxml2-dev libzip-dev libpq-dev zip unzip && docker-php-ext-install pdo_pgsql pgsql mbstring exif pcntl bcmath zip && apt-get clean && rm -rf /var/lib/apt/lists/*

    COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

    WORKDIR /app

    COPY composer.json composer.lock ./
    RUN composer install --no-dev --prefer-dist --ignore-platform-req=ext-pcntl
    --ignore-platform-req=ext-posix --no-scripts --no-autoloader

    COPY . .
    RUN composer dump-autoload --optimize && php artisan storage:link --force

    RUN chmod -R 775 storage bootstrap/cache

    EXPOSE 8000

    CMD ["/bin/sh", "-c", "php artisan migrate --force && php -S 0.0.0.0:8000 -t public"]
