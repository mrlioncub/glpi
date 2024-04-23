FROM php:8.2-apache-bookworm

LABEL org.opencontainers.image.source https://github.com/mrlioncub/glpi

ARG GLPI_VERSION=10.0.14
ARG CAS_VERSION=1.6.1

RUN set -ex; \
  apt update; \
  apt install -y --no-install-recommends \
    zlib1g-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype-dev \
    libwebp-dev \
    libicu-dev \
    libldap-dev \
    libsasl2-dev \
    libzip-dev \
    libbz2-dev; \
  docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp; \
  docker-php-ext-configure intl; \
  docker-php-ext-configure ldap --with-ldap-sasl --with-libdir="lib/$(dpkg-architecture --query DEB_BUILD_MULTIARCH)"; \
  docker-php-ext-configure bz2; \
  docker-php-ext-install -j "$(nproc)" \
    mysqli \
    gd \
    intl \
    ldap \
    opcache \
    exif \
    zip \
    bz2; \
  curl -fsSL -o /tmp/CAS.tgz https://github.com/apereo/phpCAS/releases/download/${CAS_VERSION}/CAS-${CAS_VERSION}.tgz; \
  pear install /tmp/CAS.tgz; \
  rm /tmp/CAS.tgz; \
  dpkg-query -W -f='${Package}\n' | grep '\-dev' | xargs apt remove -y; \
  apt remove -y bzip2-doc; \
  rm -rf /var/lib/apt/lists/*

RUN set -ex; \
  curl -fsSL -o /tmp/glpi.tgz https://github.com/glpi-project/glpi/releases/download/${GLPI_VERSION}/glpi-${GLPI_VERSION}.tgz; \
  tar --transform='flags=r;s/^glpi//' -xzf /tmp/glpi.tgz -C /var/www/html; \
  rm /tmp/glpi.tgz; \
  chown 33:33 -R /var/www/html

RUN <<EOT cat > /etc/apache2/sites-available/glpi.conf
<VirtualHost *:80>
    DocumentRoot /var/www/html/public
    <Directory /var/www/html/public>
        Require all granted
        RewriteEngine On
        RewriteCond %{REQUEST_FILENAME} !-f
        RewriteRule ^(.*)$ index.php [QSA,L]
    </Directory>
</VirtualHost>
EOT

RUN set -ex; \
  mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"; \
  sed -e '/session.cookie_httponly/s/=.*/= On/' -i "$PHP_INI_DIR/php.ini"; \
  rm /etc/apache2/sites-enabled/000-default.conf; \
  a2enmod rewrite; \
  a2ensite glpi

COPY docker-glpi-entrypoint /usr/local/bin/

ENTRYPOINT ["docker-glpi-entrypoint"]

CMD ["apache2-foreground"]
