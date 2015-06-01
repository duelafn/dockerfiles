
Volume Initialization
=====================

Just run container.

When run, a new database will be initialized if data/mysql folder is
missing. If auto-initialized, a random root password will be generated and
stored in etc/admin.cnf for later connections.

If using an existing database, extract it to the volume in data/. Is is
recommended that you create etc/admin.cnf containing root (or ather
administrator) connection information so that the docker scripts function
correctly.

    [client]
    user     = root
    password = a_password
    socket   = /opt/mariadb/socket/mysqld.sock


Volume Layout
=============

VOLUME: /opt/mariadb/

Mariadb data dir is /opt/mariadb/data/

Database socket at /opt/mariadb/socket/mysqld.sock

Administration (root) connection info in /opt/mariadb/etc/admin.cnf


Docker Scripts
==============

    docker run  ... /docker/run
    docker run  ... /docker/run_no_grant

The following require etc/admin.cnf to contain appropriate connection
information to work properly.

    docker exec ... /docker/stop

    docker exec ... /docker/mysql
    docker exec ... /docker/mysqladmin
