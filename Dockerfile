FROM php:8.3-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    zip \
    unzip \
    libpq-dev \
    && docker-php-ext-install pdo pdo_mysql mbstring exif pcntl bcmath gd zip \
    && docker-php-ext-enable opcache \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Redis extension
RUN pecl install redis && docker-php-ext-enable redis

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www

# Copy existing application directory
COPY . /var/www

# Set permissions for Laravel
RUN chown -R www-data:www-data /var/www \
    && find /var/www/storage -type d -exec chmod 775 {} \; 2>/dev/null || true \
    && find /var/www/storage -type f -exec chmod 664 {} \; 2>/dev/null || true \
    && find /var/www/bootstrap/cache -type d -exec chmod 775 {} \; 2>/dev/null || true \
    && find /var/www/bootstrap/cache -type f -exec chmod 664 {} \; 2>/dev/null || true \
    && mkdir -p /var/www/storage/logs \
    && touch /var/www/storage/logs/laravel.log \
    && chown www-data:www-data /var/www/storage/logs/laravel.log \
    && chmod 664 /var/www/storage/logs/laravel.log

# Expose port 9000 for PHP-FPM
EXPOSE 9000

CMD ["php-fpm"]
