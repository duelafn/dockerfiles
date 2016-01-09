
Volume Initialization
=====================

VOLUME: /opt/puppet

First time run with a new host name, new volume, or upon changing the
ssldir:

    docker run --rm                  \
        -h puppet.machinemotion.com  \
        -v /opt/puppet:/opt/puppet   \
        cmminc/puppetmaster:latest   \
        /docker/init

This will initialize configuration files and generate and sign a server
certificate. Press Control-C to stop the server once the certificates are
generated.

After initialization, edit configs in `/opt/puppet/etc` can be modified if
needed.

Running Container
=================

    docker run --rm                  \
        -h puppet.machinemotion.com  \
        -v /opt/puppet:/opt/puppet   \
        -p 127.0.0.1:8140:8140       \
        --name puppet3               \
        cmminc/puppetmaster:latest


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
