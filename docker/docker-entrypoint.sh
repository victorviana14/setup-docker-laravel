#!/bin/bash

# Verifica se o projeto Laravel já existe
if [ ! -d "/var/www/laravel" ]; then
    # Instala o Laravel
    # composer create-project --prefer-dist laravel/laravel lara-project

    mkdir /var/www/laravel

    git clone https://github.com/laravel/laravel.git /var/www/laraveltmp

    cp -rf /var/www/laraveltmp/* /var/www/laravel

    rsync -avz --exclude='laravel' --exclude='laraveltmp' --exclude='.docker' --exclude='docker' /var/www/ /var/www/laravel

    
    rsync -avz /var/www/laravel/ /var/www

    rm -rf /var/www/laravel

    rm -rf /var/www/laraveltmp

    # Ajusta as permissões (importante para o seu usuário local acessar os arquivos)
    # chown -R www-data:www-data /var/www/laravel
fi

# Inicia o servidor web em background
php-fpm & # Ou "apache2-foreground &", "nginx &", etc.

# Mantém o script em execução em primeiro plano (essencial!)
tail -f /dev/null
