
Volume Initialization
=====================

VOLUME: /opt/puppet

First time run with a new host name, new volume, or upon changing the
ssldir:

    docker run --rm                   \
        -h puppet.machinemotion.com   \
        -v /srv/puppet:/opt/puppet    \
        cmminc/puppet5-deb10:latest   \
        /docker/init

This will initialize configuration files and generate and sign a server
certificate. Press Control-C to stop the server once the certificates are
generated.

After initialization, edit configs in `/srv/puppet/etc` if needed.

Running Container
=================

    docker run --rm                  \
        -h puppet.machinemotion.com  \
        -v /srv/puppet:/opt/puppet   \
        -p 127.0.0.1:8140:8140       \
        --name puppet5-deb10         \
        cmminc/puppet5-deb10:latest


Client Management
=================

Clients can attempt to connect using the usual:

    sudo puppet agent --test --noop -w 60

On the docker host (iron), you will need to get a shell in the puppet
container (named puppet5-deb10 in the systemd service file) in order to
sign the certificates:

    [deans@iron ~]$ docker exec -it puppet5-deb10 bash
    root@puppet:/# puppet cert list
    root@puppet:/# puppet cert --sign iron.machinemotion.com
    root@puppet:/# exit


Completely fresh start (server and/or client):

    root@server:/# rm -rf /opt/puppet/lib/ssl
    root@client:/# rm -rf /var/lib/puppet/ssl

Remove certs for a specific client:

    root@server:/# puppet cert list --all
    root@server:/# puppet cert clean MY-CLIENT-NAME
