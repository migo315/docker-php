PHP Docker Image
========================

This is just a simple docker image for running php (eg. for symfony) with version 7.3.

EXAMPLE:
-------

```
version: '2'
services:
    nginx:
        image: nginx:latest
        ports:
            - 80:80
        volumes_from:
            - php
        links:
            - php
    php:
        image: migoapps/docker-php:3.0.0
        volumes:
            - ./:/var/www/html
            - ./docker/nginx.conf:/etc/nginx/conf.d/app.conf
        links:
            - db
    db:
        image: mariadb:latest
        ports:
            - 3306:3306
        environment:
            MYSQL_ROOT_PASSWORD: root
            MYSQL_DATABASE: coolDb
```

or with postgres:

```
version: '2'
services:
    nginx:
        image: nginx:latest
        ports:
            - 80:80
        volumes_from:
            - php
        links:
            - php
    php:
        image: migoapps/docker-php:3.0.0
        volumes:
            - ./:/var/www/html
            - ./docker/nginx.conf:/etc/nginx/conf.d/app.conf
        links:
            - db
    db:
        image: postgres
        environment:
            POSTGRES_USER: db
            POSTGRES_PASSWORD: db
            POSTGRES_DB: data
```
