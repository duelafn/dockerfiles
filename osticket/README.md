
Volume Initialization
=====================

Launch:

    docker run -it --rm --hostname ticket.machinemotion.com --name osticket-data -v /opt/osticket/data:/opt/mariadb mariadb

Set up Database:

    docker exec -it osticket-data /docker/mysqladmin create osticket
    docker exec -it osticket-data /docker/mysql

    CREATE USER 'osticket'@'%' IDENTIFIED BY 'a_password';
    GRANT ALTER, CREATE VIEW, CREATE, DELETE, DROP, GRANT OPTION, INDEX, INSERT, SELECT, SHOW VIEW, TRIGGER, UPDATE ON osticket.* TO 'osticket'@'%';
    FLUSH PRIVILEGES;

Launch:

    docker run -it --rm --hostname ticket.machinemotion.com --name osticket --link osticket-data:osticket-data \
        -e MAILHUB=172.17.42.1 -p 127.0.0.1:3280:80 -v /opt/osticket:/opt/osticket osticket

Visit: http://ticket.machinemotion.com/ to run the setup script.
