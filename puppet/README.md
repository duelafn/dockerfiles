
Volume Initialization
=====================

VOLUME: /opt/puppet

Copy your puppet.conf to etc/puppet.conf in the volume. This file is
symlinked from /etc/puppet in the chroot. At the very least, you will
probably want:

    [main]
    confdir=/opt/puppet
    logdir=/opt/puppet/log
    vardir=/opt/puppet/lib
    ssldir=/opt/puppet/lib/ssl
    rundir=/var/run/puppet
    factpath=$vardir/facter

    [master]
    environmentpath=/opt/puppet/environments

Ensure that lib and log directories are writable by puppet UID.

    sudo install -d -o 200 -g 200 /opt/puppet/log /opt/puppet/lib

Create an appropriate extra/apache2/puppetmaster-passenger.conf in your
volume (you may want to use the debian-supplied one as a starting point).
Make sure that the certificate files point to your puppet `ssldir`.


If running for the first time, you need to generate new certificates (only
need to specify host name and volumes, no need to export the service yet):

    docker run --rm                  \
        -h puppet.machinemotion.com  \
        -v /opt/puppet:/opt/puppet   \
        cmminc/puppetmaster:latest   \
        puppet master --verbose --no-daemonize

Press Control-C to stop the server once the certificates are generated.


Client Management
=================

Clients can attempt to connect using the usual:

    sudo puppet agent --test --noop -w 60

On the docker host (iron), you will need to get a shell in the puppet
container (named puppet3 in the systemd service file) in order to sign the
certificates:

    [deans@iron ~]$ docker exec -it puppet3 bash
    root@puppet:/# puppet cert list
    root@puppet:/# puppet cert --sign iron.machinemotion.com
    root@puppet:/# exit
