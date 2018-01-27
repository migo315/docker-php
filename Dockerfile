FROM ubuntu:17.10

MAINTAINER Michel Chowanski version 1.3

################## PHP ##################
RUN apt-get update && apt-get install -y php7.1-fpm \
 openssl \
 php7.1 \
 php7.1-mysql \
 php7.1-pgsql \
 php7.1-curl \
 php7.1-xml \
 php-xdebug \
 php7.1-mbstring

# configure php fpm
RUN sed -i -e "s/;date.timezone =.*/date.timezone = 'Europe\/Berlin'/g" /etc/php/7.1/fpm/php.ini && \
    sed -i -e "s/post_max_size =.*/post_max_size = 100M/g" /etc/php/7.1/fpm/php.ini && \
    sed -i -e "s/upload_max_filesize =.*/upload_max_filesize = 80M/g" /etc/php/7.1/fpm/php.ini && \
    sed -i -e "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" /etc/php/7.1/fpm/php.ini && \
    sed -i -e "s/short_open_tag = Off/short_open_tag = On/g" /etc/php/7.1/fpm/php.ini && \
    sed -i -e "s/memory_limit = .*/memory_limit = 512M/g" /etc/php/7.1/fpm/php.ini && \
    sed -i -e "s/.*date.timezone = .*/date.timezone = 'UTC'/g" /etc/php/7.1/fpm/php.ini && \
    sed -i -e "s/;error_log = .*/error_log = \/proc\/self\/fd\/1/g" /etc/php/7.1/fpm/php-fpm.conf && \
    sed -i -e 's/^listen =.*/listen = \[::\]:9000/g' /etc/php/7.1/fpm/pool.d/www.conf && \
    sed -i -e 's/.*listen\.owner.*/listen.owner = www-data/g' /etc/php/7.1/fpm/pool.d/www.conf && \
    sed -i -e 's/.*listen\.group.*/listen.group = www-data/g' /etc/php/7.1/fpm/pool.d/www.conf && \
    sed -i -e 's/^listen.allowed_clients.*/listen.allowed_clients = any/g' /etc/php/7.1/fpm/pool.d/www.conf && \
    sed -i -e "s/;catch_workers_output\s*=\s*yes/catch_workers_output = yes/g" /etc/php/7.1/fpm/pool.d/www.conf && \
    sed -i -e "s/.*pm.max_children =.*/pm.max_children = 9/g" /etc/php/7.1/fpm/pool.d/www.conf && \
    sed -i -e "s/.*pm.start_servers =.*/pm.start_servers = 3/g" /etc/php/7.1/fpm/pool.d/www.conf && \
    sed -i -e "s/.*pm.min_spare_servers =.*/pm.min_spare_servers = 2/g" /etc/php/7.1/fpm/pool.d/www.conf && \
    sed -i -e "s/.*pm.max_spare_servers =.*/pm.max_spare_servers = 4/g" /etc/php/7.1/fpm/pool.d/www.conf && \
    sed -i -e "s/.*pm.max_requests =.*/pm.max_requests = 300/g" /etc/php/7.1/fpm/pool.d/www.conf && \
    sed -i -e "s/.*php_admin_value\[error_log\].*/php_admin_value[error_log] = \/proc\/self\/fd\/1/g" /etc/php/7.1/fpm/pool.d/www.conf && \
    sed -i -e "s/.*php_admin_value\[log_errors\].*/php_admin_value[log_errors] = on/g" /etc/php/7.1/fpm/pool.d/www.conf

RUN mkdir -p /run/php

################## UNZIP / SUPERVISOR ##################
RUN apt-get install -y unzip \
 supervisor
ADD supervisor/startup.conf /etc/supervisor/conf.d/startup.conf
ADD run.sh /run.sh
RUN chmod +x /run.sh

################## CURL ##################
RUN apt-get -qqy install curl

################## COMPOSER ##################
RUN curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer

################## XDEBUG ##################
RUN echo "zend_extension=/usr/lib/php/20151012/xdebug.so" > /etc/php/7.1/mods-available/xdebug.ini
RUN echo "xdebug.remote_enable=0" >> /etc/php/7.1/mods-available/xdebug.ini
RUN echo "xdebug.remote_port=9001" >> /etc/php/7.1/mods-available/xdebug.ini
RUN echo "xdebug.idekey=PHPSTORM" >> /etc/php/7.1/mods-available/xdebug.ini
RUN echo "xdebug.remote_log = /var/log/nginx/xdebug_remote.log" >> /etc/php/7.1/mods-available/xdebug.ini
RUN echo "xdebug.remote_autostart=1" >> /etc/php/7.1/mods-available/xdebug.ini

WORKDIR /var/www/html

################## APT-FILES ##################
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

################## VOLUMES ##################
VOLUME /var/www/html

################## PORT ##################
EXPOSE 80 443 9000

################## COMMAND ##################
CMD ["/bin/bash", "/run.sh"]