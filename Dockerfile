FROM php:7.4-apache

# Use only valid archive mirror for Bullseye
RUN echo "deb http://archive.debian.org/debian bullseye main" > /etc/apt/sources.list

COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/

RUN apt-get -o Acquire::Check-Valid-Until=false update \
    && install-php-extensions pdo_mysql mysqli intl mbstring gd zip xml opcache

# Enable Apache mod_rewrite & headers
RUN a2enmod rewrite headers

# Configure Apache AllowOverride All for .htaccess support
RUN printf '<Directory /var/www/html/>\n    Options -Indexes +FollowSymLinks\n    AllowOverride All\n    Require all granted\n</Directory>\n' > /etc/apache2/conf-available/override.conf \
    && a2enconf override

COPY deploy/apache-security.conf /etc/apache2/conf-available/meduc-security.conf
RUN a2enconf meduc-security

# Custom PHP settings for CakePHP / MedUC
RUN printf 'memory_limit=512M\nupload_max_filesize=100M\npost_max_size=100M\nmax_execution_time=300\ndate.timezone=Asia/Ho_Chi_Minh\ndisplay_errors=Off\ndisplay_startup_errors=Off\nlog_errors=On\nerror_reporting=E_ALL & ~E_DEPRECATED & ~E_STRICT & ~E_NOTICE\n' > /usr/local/etc/php/conf.d/custom.ini

WORKDIR /var/www/html
