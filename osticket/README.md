
Volume Initialization
=====================

Set up sources in /srv/osticket/www either from tarball or from git clone:

    cd /opt/osticket
    git clone https://github.com/osTicket/osTicket src

    docker run -it --rm --hostname ticket.machinemotion.com --name osticket osticket bash
    cd /opt/osticket/src
    php setup/cli/manage.php deploy -setup /opt/osticket/www/

Launch database instance:

    docker run -it --rm --hostname ticket.machinemotion.com --name osticket-data -v /srv/osticket/data:/opt/mariadb mariadb

Set up Database:

    docker exec -it osticket-data /docker/mysqladmin create osticket
    docker exec -it osticket-data /docker/mysql

    CREATE USER 'osticket'@'%' IDENTIFIED BY 'a_password';
    GRANT ALTER, CREATE VIEW, CREATE, DELETE, DROP, GRANT OPTION, INDEX, INSERT, SELECT, SHOW VIEW, TRIGGER, UPDATE ON osticket.* TO 'osticket'@'%';
    FLUSH PRIVILEGES;

Launch osticket instance:

    docker run -it --rm --hostname ticket.machinemotion.com --name osticket --link osticket-data:osticket-data \
        -e MAILHUB=172.17.42.1 -p 127.0.0.1:3280:80 -v /srv/osticket:/opt/osticket osticket

Visit: http://ticket.machinemotion.com/ to run the setup script.

After setup remove the setup scripts for security:

    rm -rf /opt/osticket/www/setup


Git-based Upgrades
==================

    cd /srv/osticket/src
    git fetch
    git checkout v1.9.12      # for example

    docker exec -it osticket bash
    cd /opt/osticket/src
    php setup/cli/manage.php deploy -v /opt/osticket/www/
