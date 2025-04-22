#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Print each command before executing
set -x

# Go to workspace directory
cd /workspace

# Install PHP dependencies
composer install

# Create .env if it doesn't exist
if [ ! -f .env ]; then
    cp .env.example .env
    php artisan key:generate
fi

# Update environment variables for Codespaces
sed -i 's/DB_HOST=.*/DB_HOST=db/' .env
sed -i 's/DB_DATABASE=.*/DB_DATABASE=smart_light_system/' .env
sed -i 's/DB_USERNAME=.*/DB_USERNAME=laravel/' .env
sed -i 's/DB_PASSWORD=.*/DB_PASSWORD=secret/' .env
sed -i 's/APP_URL=.*/APP_URL=https:\/\/${CODESPACE_NAME}-8000.${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN}/' .env

# Wait for MySQL to be ready
echo "Waiting for MySQL database to be ready..."
until mysqladmin ping -h db -u root -proot --silent; do
    sleep 1
done
echo "MySQL is ready!"

# Run migrations and seeders
php artisan migrate:fresh --seed

# Install NPM dependencies
npm ci
npm run build

# Create storage link
php artisan storage:link

echo "Laravel Smart Light Dashboard setup is complete!"