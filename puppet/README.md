
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


Create an appropriate extra/apache2/puppetmaster-passenger.conf in your
volume (you may need to copy from the debian-supplied one).


With these files and suitable puppet manifests in place, the chroot is
ready to run.
