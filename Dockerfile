FROM php:8.3-fpm

# set your user name, ex: user=carlos
ARG user=victornodocker
ARG uid=1000

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    rsync \
    zip \
    unzip

# Install Node.js and npm
RUN curl -fsSL https://deb.nodesource.com/setup_current.x | bash - \
    && apt-get install -y nodejs

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd sockets

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Create system user to run Composer and Artisan Commands
RUN useradd -G www-data,root -u $uid -d /home/$user $user
RUN mkdir -p /home/$user/.composer && \
    chown -R $user:$user /home/$user

# Install redis
RUN pecl install -o -f redis \
    &&  rm -rf /tmp/pear \
    &&  docker-php-ext-enable redis

# Set working directory
WORKDIR /var/www

# Install Tailwind CSS
# RUN npm install tailwindcss @tailwindcss/forms @tailwindcss/typography postcss postcss-nesting autoprefixer --save-dev

# Copy custom configurations PHP
COPY docker/php/custom.ini /usr/local/etc/php/conf.d/custom.ini

# Copia o script entrypoint.sh para dentro do container
COPY docker/docker-entrypoint.sh /entrypoint.sh

# Define as permissões de execução para o script
RUN chmod +x /entrypoint.sh

# Ajustar permissões (opcional)
RUN chown -R www-data:www-data /var/www

# Build assets
# RUN npm run build

# Define o entrypoint para executar o script
ENTRYPOINT ["/entrypoint.sh"]


USER $user

# Comando a ser executado quando o container iniciar (ex: iniciar o servidor web) - ajuste conforme sua necessidade
CMD ["php-fpm"] 
# "php-fpm" Ou "apache2-foreground", "nginx", etc.