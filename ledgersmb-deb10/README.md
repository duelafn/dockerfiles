
Volume Initialization
=====================

Run the container

    docker run --rm
        -h serenevy.net
        -v /srv/ledger:/www
        -p 127.0.0.1:5000:5000
        --network ledger
        --name ledger
        duelafn/ledgersmb-deb10:latest

On first run, configuration files wiull be created in $VOLUME/etc. Edit
those files and restart the container.


Volume Layout
=============

VOLUME: `/www`

* $VOLUME/etc/ledgersmb.conf

    LedgerSMB configuration.

* $VOLUME/etc/starman.conf

    Starman additional configuration. A line-based file containing option
    and value pairs separated by whitespace.

* $VOLUME/log/error.log

    Location of the error log under the default settings.

* $VOLUME/run/starman.sock

    Location of unix domain socket which a reverse proxy could connect to.


Docker Scripts
==============

    docker run  ... /docker/run

    docker exec ... /docker/stop        # graceful shutdown
    docker exec ... /docker/reload      # graceful reload

    docker exec ... /docker/kill        # un-graceful shutdown

    docker exec ... /docker/addworker   # Increase number of worker processes
    docker exec ... /docker/rmworker    # Decrease number of worker processes
