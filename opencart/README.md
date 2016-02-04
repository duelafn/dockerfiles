
Volume Initialization
=====================

Launch database instance:

    docker run -it --rm --hostname store.routerbitclub.com --name opencart-data -v /srv/opencart/data:/opt/mariadb cmminc/mariadb

Set up Database:

    docker exec -it opencart-data /docker/mysqladmin create opencart
    docker exec -it opencart-data /docker/mysql

    CREATE USER 'opencart'@'%' IDENTIFIED BY 'a_password';
    GRANT ALTER, CREATE VIEW, CREATE, DELETE, DROP, GRANT OPTION, INDEX, INSERT, SELECT, SHOW VIEW, TRIGGER, UPDATE ON opencart.* TO 'opencart'@'%';
    FLUSH PRIVILEGES;

When you first run this docker image it will load the bleeding-edge
opencart from github. If you want to run the stable version you should
download it and copy the "upload" directory to /srv/opencart/www:

    cd /srv/opencart
    # rm -rf www       # <- DANGER!
    cp -r $OPENCART_SOURCE/upload www

Launch opencart instance:

    docker run -it --rm --hostname store.routerbitclub.com --name opencart --link opencart-data:opencart-data \
        -e MAILHUB=172.17.42.1 -p 127.0.0.1:3380:80 -v /srv/opencart:/opt/opencart utgllc/opencart

docker run -it --rm --hostname store.routerbitclub.com --name opencart --link opencart-data:opencart-data -e MAILHUB=172.17.42.1 -p 127.0.0.1:3380:80 -v /opt/opencart:/opt/opencart utgllc/opencart

Visit: http://store.routerbitclub.com/ to run the installation script.

After setup remove the install directory for security:

    rm -rf /srv/opencart/www/install


Volume Layout
=============

VOLUME: /opt/opencart


Docker Scripts
==============

    docker run  ... /docker/run
    docker exec ... /docker/reload
    docker exec ... /docker/stop
