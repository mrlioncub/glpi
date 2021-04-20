![GLPI Logo](https://raw.githubusercontent.com/glpi-project/glpi/master/pics/logos/logo-GLPI-250-black.png)

[![Build Status](https://img.shields.io/docker/cloud/build/mrlioncub/glpi)](https://hub.docker.com/r/mrlioncub/glpi)
[![Docker Automated build](https://img.shields.io/docker/cloud/automated/mrlioncub/glpi)](https://hub.docker.com/r/mrlioncub/glpi)
[![Docker Image Size](https://img.shields.io/docker/image-size/mrlioncub/glpi/latest)](https://hub.docker.com/r/mrlioncub/glpi)

## About GLPI

GLPI stands for **Gestionnaire Libre de Parc Informatique** is a Free Asset and IT Management Software package, that provides ITIL Service Desk features, licenses tracking and software auditing.

GLPI features:
* Inventory of computers, peripherals, network printers and any associated components through an interface, with inventory tools such as: [FusionInventory](http://fusioninventory.org/) or [OCS Inventory](https://www.ocsinventory-ng.org/)
* Data Center Infrastructure Management (DCIM)
* Item lifecycle management
* Licenses management (ITIL compliant)
* Management of warranty and financial information (purchase order, warranty and extension, damping)
* Management of contracts, contacts, documents related to inventory items
* Incidents, requests, problems and changes management
* Knowledge base and Frequently-Asked Questions (FAQ)
* Asset reservation

Moreover, GLPI supports many [plugins](http://plugins.glpi-project.org) that provide additional features.

## Demonstration

Check GLPI features by asking a free personnal demonstration on **[glpi-network.cloud](https://www.glpi-network.cloud)**

## License

![license](https://img.shields.io/github/license/glpi-project/glpi.svg)

It is distributed under the GNU GENERAL PUBLIC LICENSE Version 2 - please consult the file called [COPYING](https://raw.githubusercontent.com/glpi-project/glpi/master/COPYING.txt) for more details.

## Using the image

The image contains a webserver and exposes port 80. To start the container type:

```console
$ docker run -d -p 8080:80 mrlioncub/glpi
```

Now you can access GLPI at http://localhost:8080/ from your host system.

## Using an external database

By default, this container uses setup wizard (appears on first run) allows connecting to an existing MySQL/MariaDB database. You can also link a database container, e. g. `--link my-mysql:db`, and then use `db` as the database host on setup. More info is in the docker-compose section.

## Persistent data

The GLPI installation and all data beyond what lives in the database (file uploads, etc.) are stored in the [unnamed docker volume](https://docs.docker.com/engine/tutorials/dockervolumes/#adding-a-data-volume) volume `/var/www/html/files`, `/var/www/html/config` and `/var/www/html/marketplace`. The docker daemon will store that data within the docker directory `/var/lib/docker/volumes/...`. That means your data is saved even if the container crashes, is stopped or deleted.

A named Docker volume or a mounted host directory should be used for upgrades and backups. To achieve this, you need one volume for your database container and three for GLPI.

GLPI:

- `/var/www/html/files`,`/var/www/html/config`,`/var/www/html/marketplace` folders where all GLPI data lives

    ```console
    $ docker run -d \
    -v glpi_files:/var/www/html/files \
    -v glpi_config:/var/www/html/config \
    -v glpi_marketplace:/var/www/html/marketplace \
    mrlioncub/glpi
    ```

Database:

- `/var/lib/mysql` MySQL / MariaDB Data

    ```console
    $ docker run -d \
    -v db:/var/lib/mysql \
    mariadb
    ```

## Using the GLPI command-line interface

To use the [GLPI command-line interface](https://glpi-install.readthedocs.io/en/latest/command-line.html):

```console
$ docker exec --user www-data CONTAINER_ID php bin/console
```

or for docker-compose:

```console
$ docker-compose exec --user www-data glpi php bin/console
```

## Auto configuration via environment variables

The GLPI image supports auto configuration via environment variables. You can preconfigure everything that is asked on the install page on first run. To enable auto configuration, set your database connection via the following environment variables.

- `DB_NAME` Database name.
- `DB_USER` Database user name.
- `DB_PASSWORD` Database user’s pasword.
- `DB_HOST` Host name.
- `DB_PORT` Database port (default MySQL port if option is not defined).
- `DEFAULT_LANGUAGE` Default language of GLPI (en_GB per default).

# Running this image with docker-compose

The easiest way to get a fully featured and functional setup is using a docker-compose file. There are too many different possibilities to setup your system, so here are only some examples of what you have to look for.

In every case, you would want to add a database container and docker volumes to get easy access to your persistent data. When you want to have your server reachable from the internet, adding HTTPS-encryption is mandatory! See below for more information.

## Base version

This version will use the GLPI image and add a mariaDB container. The volumes are set to keep your data persistent. This setup provides **no ssl encryption** and is intended to run behind a proxy.

Make sure to pass in values for `MYSQL_ROOT_PASSWORD` and `MYSQL_PASSWORD` variables before you run this setup in the variables file .env. Make sure to pass in values for `MYSQL_ROOT_PASSWORD` and `MYSQL_PASSWORD` variables before you run this setup in the variables file .env. It's possible to pass in values for `PATH_DB`, `PATH_FILES`, `PATH_CONFIG`,  `PATH_MARKETPLACE` or run command: `mkdir {db,files,config,marketplace}` in the same directory.

https://github.com/mrlioncub/glpi/blob/main/docker-compose.yaml

Then run `docker-compose up -d`, now you can access GLPI at http://localhost:8080/ from your host system.

# Update to a newer version

Updating the GLPI container is done by pulling the new image, throwing away the old container and starting the new one.

Since all data is stored in volumes, nothing gets lost. The startup script will check for the version in your volume and the installed docker version. If it finds a mismatch, it automatically starts the upgrade process. Don't forget to add all the volumes to your new container, so it works as expected.

```console
docker pull mrlioncub/glpi
docker stop <your_glpi_container>
docker rm <your_glpi_container>
docker run <OPTIONS> -d mrlioncub/glpi
```

Beware that you have to run the same command with the options that you used to initially start your GLPI. That includes volumes, port mapping.

When using docker-compose your compose file takes care of your configuration, so you just have to run:

```console
docker-compose pull
docker-compose up -d
```
