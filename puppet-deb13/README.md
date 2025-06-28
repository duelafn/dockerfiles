
Volume Initialization
=====================

VOLUME: /opt/puppet

First time run with a new host name, new volume, or upon changing the
ssldir or SSL options (e.g., ca_ttl):

    docker run --rm                \
        -h puppet.example.com      \
        -v /srv/puppet:/opt/puppet \
        cmminc/puppet:deb13        \
        /docker/init

After initialization, edit configs in `/srv/puppet/etc` if needed.

Suggested configuration modifications:

puppet.conf:

    [master]
    autosign = false

Running Container
=================

    docker run --rm                \
        -h puppet.example.com      \
        -v /srv/puppet:/opt/puppet \
        -p 127.0.0.1:8140:8140     \
        --name puppet-deb13        \
        cmminc/puppet:deb13


Client Management
=================

Clients can attempt to connect using the usual:

    sudo puppet agent --test --noop --waitforcert 10

On the puppetserver container sign the certificates:

    [user@server ~]$ sudo docker exec -it puppet-deb13 bash
    root@puppet:/# puppetserver ca list
    root@puppet:/# puppetserver ca sign --certname client.example.com
    root@puppet:/# exit


Completely fresh start (server and/or client):

    root@server:/# puppetserver ca delete --all
    root@server:/# puppetserver ca setup
    root@client:/# puppet ssl clean --localca

Remove certs for a specific client:

    root@server:/# puppetserver ca list --all
    root@server:/# puppetserver ca clean --certname client.example.com
