
Volume Initialization
=====================

Just run container.

When run, a new database will be initialized if data/mysql folder is
missing. If using an existing database, extract it to the volume in data/.


Volume Layout
=============

VOLUME: /opt/mariadb/

Mariadb data dir is /opt/mariadb/data/

Database socket at /opt/mariadb/socket/mariadbd.sock

Administration (root) connection info in /opt/mariadb/etc/admin.cnf


Upgrading
=========

Debian 11 no longer uses the admin.cnf connection permission file. Instead,
it uses an authorized mysql system user.


Docker Scripts
==============

    docker run  ... /docker/run
    docker run  ... /docker/run_no_grant

The following require etc/admin.cnf to contain appropriate connection
information OR for the the root user to have unix socket authentication
enabled to work properly.

    GRANT ALL PRIVILEGES ON *.* TO root@hostname IDENTIFIED VIA unix_socket;

    docker exec ... /docker/stop

    docker exec -u mysql ... /docker/mariadb
    docker exec -u mysql ... /docker/mariadb-admin
    docker exec -u mysql ... /docker/mariadb-dump

So, for example, a backup can be performed using:

    docker exec -u mysql -it osticket-data /docker/mariadb-dump --all-databases --single-transaction | gzip -c > osticket_2015-12-05.sql.gz
