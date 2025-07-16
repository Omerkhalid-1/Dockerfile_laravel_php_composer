# Stage 1: Build stage
FROM php:8.2.12-cli AS builder

WORKDIR /var/www/html

# Install the required dependencies and tools
RUN apt-get update && apt-get install -y \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    && rm -rf /var/lib/apt/lists/*

# Install same PHP extensions as build stage
RUN docker-php-ext-install \
    pdo_mysql \
    mbstring \
    zip \
    bcmath

# Download and install composer Version 2.8.9, Install to system path, name the file composer.
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer --version=2.8.9

# Create a laravel build with stable version v10.0.0
RUN composer create-project --prefer-dist laravel/laravel:v10.0.0 .

RUN composer install --optimize-autoloader --no-dev

# Stage 2: Runtime stage
FROM php:8.2.12-fpm

WORKDIR /var/www/html

# install only run-time library( no build )
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    && rm -rf /var/lib/apt/lists/*

# install php extensions 
RUN docker-php-ext-install \
    pdo_mysql \
    mbstring \
    zip \
    bcmath

# Copy Laravel application from builder stage
COPY --from=builder /var/www/html /var/www/html

# change ownership of the files so php-fpm can read and write laravel files
RUN chown -R www-data:www-data /var/www/html

# Port listens on port 9000 
EXPOSE 9000

# Start php-fpm deamon when container starts
CMD ["php-fpm"]

# Build Command
# Docker build -t ms-php8.2.12_composer2.8.9_laravel10.48 .
# docker images | grep ms-php8.2.12_composer2.8.9_laravel10.48  
# Docker run -d -p 9000:9000 <image_name>