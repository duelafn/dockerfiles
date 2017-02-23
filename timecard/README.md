
Volume Initialization
=====================

The timeclock root should be cloned into VOLUME/www/ (VOLUME/www/index.php
should exist). For example:

   cd VOLUME
   git clone https://github.com/duelafn/timeclock www

Then run container. A reasonable default apache configuration will be
created if needed.


Volume Layout
=============

VOLUME: /opt/timeclock

Container apache configuration is stored in VOLUME/etc/site.conf


Linked Containers
=================

Create a linked mariadb instance named timeclock-data.


Host Configuration
==================

Create an nginx reverse proxy on the host to manage ssl.


Docker Scripts
==============

    docker run  ... /docker/run
    docker exec ... /docker/reload
    docker exec ... /docker/stop
