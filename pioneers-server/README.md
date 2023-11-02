
Volume Initialization
=====================

Just run container. Examples:

    # Able to launch game servers:
    docker run --rm -e PIONEERS_PORTS=7000-8000 -p 5557:5557 -p 7000-8000:7000-8000 duelafn/pioneers-server:deb12

    # Metaserver only (may still run server manually):
    docker run --rm -p 5557:5557 -p 7000-8000:7000-8000 duelafn/pioneers-server:deb12


Volume Layout
=============

VOLUME: /usr/share/games/pioneers


Docker Scripts
==============

    docker run  ... /docker/run
    docker exec ... /docker/stop

    docker exec ... /docker/server -p 7000  -P 5 ...    # manually run pioneers-server-console
