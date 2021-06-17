FROM node:14.15 AS node
FROM php:7.4-fpm
RUN apt-get update -y \
    && apt-get install -y nginx


COPY --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules
COPY --from=node /usr/local/bin/node /usr/local/bin/node
RUN ln -s /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm

RUN curl -s http://getcomposer.org/installer | php && \
    echo "export PATH=${PATH}:/var/www/vendor/bin" >> ~/.bashrc && \
    mv composer.phar /usr/local/bin/composer

ADD app.conf /etc/nginx/conf.d/app.conf
COPY entrypoint.sh /etc/entrypoint.sh
RUN chmod +x /etc/entrypoint.sh
#RUN mkdir arabeasy-v2/
COPY . /var/www
COPY --chown=33:33 . /var/www
RUN chown -R www-data:www-data /var/www
WORKDIR /var/www

RUN npm install
RUN apt-get update
RUN apt install zip unzip
#RUN apt-get install git
RUN composer install

RUN docker-php-ext-install pdo pdo_mysql

RUN apt-get update && apt-get install -y libjpeg-dev libpng-dev
#RUN apt-get install mysql-client-8.0
RUN docker-php-ext-configure gd --enable-gd --with-jpeg
RUN docker-php-ext-install gd

EXPOSE 80 443
ENTRYPOINT ["/etc/entrypoint.sh"]



