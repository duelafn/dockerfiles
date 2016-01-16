
Volume Initialization
=====================

Catalyst image used for several of our sites.

    docker run --rm -h riverbendmath.org -p 127.0.0.1:3000:5000 -v /www/riverbendmath:/www -v /cache/SparkleShare/Lessons/Modules:/www/root/modules/Modules --name riverbendmath catalyst:latest

See the starman base image for more info.

    // Passes http://riverbendmath.org/ as "Host" header value:
    ProxyPass "/" "unix:/www/riverbendmath/run/starman.sock|http://riverbendmath.org/"
