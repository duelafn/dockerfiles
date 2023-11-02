
Volume Initialization
=====================

Just run container. The config will be automatically initialized.

A client installation need only expose the GUI port:

    docker run --rm -h tsalmoth.serenevy.net -v /srv/syncthing:/opt/syncthing -p 127.0.0.1:8384:8384 --name syncthing utgllc/syncthing:deb12

A server installation really should be remotely accessible:

    docker run --rm -h syncthing.machinemotion.com -v /srv/syncthing:/opt/syncthing -p 127.0.0.1:8384:8384 -p 22000:22000 -p 21025:21025/udp --name syncthing utgllc/syncthing:deb12



Volume Layout
=============

VOLUME: /opt/syncthing


Docker Scripts
==============

    docker run  ... /docker/run
    docker exec ... /docker/stop
