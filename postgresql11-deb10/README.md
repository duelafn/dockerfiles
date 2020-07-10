
Running the container
=====================

    docker run --rm
        -h example.com
        -v /srv/mysite/data:/opt/postgresql
        --network MYNETWORKNAME
        --name postgresql
        duelafn/postgresql11-deb10:latest

Volume Initialization
=====================

Starting the container will copy configuration files to the volume if they
do not exist and will initialize the database if one does not exist.

On the first run when the database is initialized, the encoding can be set
via the `ENCODING` environment variable. The default encoding is UTF-8.

Granting Access
---------------

The default configuration will not grant any usable access rights. You will
need to either expose a unix socket, or configure `pg_hba.conf` to grant
access across the network.

### unix socket

To export the postgres, set `unix_socket_directories` in postgresql.conf to
your desired location *in addition to* its default value. For example:

    unix_socket_directories = '/var/run/postgresql,/opt/postgres/sock'

If you do not include the default path, then command-line actions such as
`createdb` or `pg_dumpall` will not work.

### network access

To allow password access to linked docker images, you can use the following
configuration (execute from within the volume path after the first run of
the container). There is no need to expose the port 5432 if you are linking
containers.

    echo "host   all   all   samenet   md5" | sudo tee -a conf/main/pg_hba.conf

To permit external access, expose port 5432 and edit conf/main/pg_hba.conf
appropriately.


Backups and Maintenance
=======================

Remember to execute commands as the `postgres` user when connecting.

    docker exec -it -u postgres CONTAINER-NAME createuser ...
    docker exec -it -u postgres CONTAINER-NAME createdb   ...
    docker exec -it -u postgres CONTAINER-NAME pg_dumpall > backup.sql


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
