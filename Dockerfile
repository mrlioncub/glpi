FROM php:7.4-apache-buster

LABEL org.opencontainers.image.source https://github.com/mrlioncub/glpi

ARG GLPI_VERSION=9.5.9
ARG CAS_VERSION=1.4.0

RUN set -ex; \
  apt-get update; \
  apt-get install -y --no-install-recommends \
    zlib1g-dev \
    libpng-dev \
    libicu-dev \
    libldap2-dev \
    libsasl2-dev \
    libxml2-dev \
    libzip-dev \
    libbz2-dev \
    libgd3 \
    libzip4; \
  docker-php-ext-configure gd; \
  docker-php-ext-configure intl; \
  docker-php-ext-configure ldap --with-ldap-sasl --with-libdir="lib/$(dpkg-architecture --query DEB_BUILD_MULTIARCH)"; \
  docker-php-ext-configure xmlrpc; \
  docker-php-ext-configure bz2; \
  docker-php-ext-install -j "$(nproc)" \
    mysqli \
    gd \
    intl \
    ldap \
    opcache \
    xmlrpc \
    exif \
    zip \
    bz2; \
  pecl install apcu; \
  docker-php-ext-enable apcu; \
  curl -fsSL -o /tmp/CAS.tgz https://github.com/apereo/phpCAS/releases/download/${CAS_VERSION}/CAS-${CAS_VERSION}.tgz; \
  pear install /tmp/CAS.tgz; \
  curl -fsSL -o /tmp/glpi.tgz https://github.com/glpi-project/glpi/releases/download/${GLPI_VERSION}/glpi-${GLPI_VERSION}.tgz; \
  tar --transform='flags=r;s/^glpi//' -xzf /tmp/glpi.tgz -C /var/www/html; \
  rm /tmp/glpi.tgz; \
  chown 33:33 -R /var/www/html; \
  apt-get autoremove --purge -y \
    zlib1g-dev \
    libpng-dev \
    libicu-dev \
    libldap2-dev \
    libsasl2-dev \
    libxml2-dev \
    libzip-dev \
    libbz2-dev; \
  rm -rf /var/lib/apt/lists/*; \
  a2enmod rewrite;

COPY docker-glpi-entrypoint /usr/local/bin/

ENTRYPOINT ["docker-glpi-entrypoint"]

CMD ["apache2-foreground"]
