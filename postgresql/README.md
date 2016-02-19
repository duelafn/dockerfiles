
Volume Initialization
=====================

Starting the container will copy configuration files to the volume if they
do not exist and will initialize the database if one does not exist.

On the first run when the database is initialized, the encoding can be set
via the `ENCODING` environment variable. The default encoding is UTF-8.


Running the Volume
==================

If you wish to export the postgres socket to a non-standard location, set
the `unix_socket_directories` to the non standard location in
postgresql.conf in addition to its default value. For example:

    unix_socket_directories = '/var/run/postgresql,/opt/postgres/sock'


Backups and Maintenance
=======================

Remember to execute commands as the `postgres` user when connecting.

Docker >= 1.7:

    docker exec -u postgres CONTAINER-NAME createuser ...
    docker exec -u postgres CONTAINER-NAME createdb   ...
    docker exec -u postgres CONTAINER-NAME pg_dumpall > backup.sql

Docker without `-u` exec option:

    docker exec sudo -u postgres CONTAINER-NAME createuser ...
    docker exec sudo -u postgres CONTAINER-NAME createdb   ...
    docker exec sudo -u postgres CONTAINER-NAME pg_dumpall > backup.sql


Volume Layout
=============

VOLUME: /opt/postgresql

    /opt/postgresql/data: PGDATA directory
    /opt/postgresql/conf: configuration data
    /opt/postgresql/log: log data


Default Settings
================

    listen_addresses = '*'
    ssl = false

These can be changed by modifying `$VOLUME/conf/main/postgresql.conf` after
first run.

Docker Scripts
==============

    docker run  ... /docker/run      # default command
    docker exec ... /docker/reload
    docker exec ... /docker/stop
    docker exec ... /docker/pg_ctl
