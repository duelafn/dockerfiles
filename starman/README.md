
Volume Initialization
=====================

Install your app into the volume directory. On first run we will create a
default `$VOLUME/etc/starman.conf` which adds `$VOLUME/lib` to the module
path and will attempt to execute `$VOLUME/app.psgi`.

By default starman will listen on port `5000` and to
`$VOLUME/run/starman.sock`

    docker run --rm
        -h serenevy.net
        -v /srv/serenevy:/opt/starman
        -p 127.0.0.1:80:5000
        --name starman
        duelafn/starman:latest


Volume Layout
=============

VOLUME: `/opt/starman`


* $VOLUME/etc/starman.conf

    Starman configuration. A line-based file containing option and value
    pairs separated by whitespace. Options are specified by their long
    names in the starman launcher man page and will replace our defaults.
    The default values set by this script are contained in `/docker/starman.conf`.

* $VOLUME/log/error.log

    Location of the error log under the default settings.

* $VOLUME/run/starman.sock

    Location of unix domain socket which a reverse proxy could connect to.

* $VOLUME/lib

    The default `etc/starman.conf` will appeand this to the module path.

* $VOLUME/app.psgi

    The default `etc/starman.conf` will attempt to run this plack app.


Docker Scripts
==============

    docker run  ... /docker/run

    docker exec ... /docker/stop        # graceful shutdown
    docker exec ... /docker/reload      # graceful reload

    docker exec ... /docker/kill        # un-graceful shutdown

    docker exec ... /docker/addworker   # Increase number of worker processes
    docker exec ... /docker/rmworker    # Decrease number of worker processes
