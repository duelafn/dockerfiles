
Volume Initialization
=====================

Just run container.

    docker run --rm \
        -h myapp \
        -v /srv/myapp:/opt/mariadb \
        -p 127.0.0.1:3306:3306 \
        --name myapp \
        cmminc/mariadb:deb13

When run, a new database will be initialized if data/mysql folder is missing.


Volume Layout
=============

VOLUME: /opt/mariadb/

Mariadb data dir is /opt/mariadb/data/

Database socket at /opt/mariadb/socket/mariadbd.sock


docker run --rm -v /opt/osticket/data:/opt/mariadb --name cc cmminc/mariadb:deb13
docker run --rm -v /opt/timeclock/data:/opt/mariadb --name cc cmminc/mariadb:deb13

docker exec -it cc mariadb --defaults-file=/opt/mariadb/etc/admin.cnf --socket=/opt/mariadb/socket/mariadb.sock
GRANT ALL PRIVILEGES ON *.* TO root@localhost IDENTIFIED VIA unix_socket; FLUSH PRIVILEGES;
docker exec -it cc mariadb-upgrade
docker exec -it cc /docker/stop


Upgrading
=========

MariaDB recommends full dump and restore for major upgrades.

Debian no longer uses the admin.cnf connection permission file. Instead,
the root and mysql system users are authorized with full privileges.


Docker Scripts
==============

    docker run  ... /docker/run
    docker run  ... /docker/run_no_grant
    docker exec ... /docker/stop

    docker exec ... /docker/mariadb
    docker exec ... /docker/mariadb-admin
    docker exec ... /docker/mariadb-dump

So, for example, a backup can be performed using:

    docker exec -it osticket-data /docker/mariadb-dump --all-databases --single-transaction | gzip -c > osticket_2015-12-05.sql.gz
