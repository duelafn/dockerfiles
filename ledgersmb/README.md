
Volume Initialization
=====================

Link to a postgresql instance with a configured superuser.

    docker run --rm  -h ledger.serenevy.net  -v /srv/ledgersmb:/www --name ledgersmb --link ledgersmb-data:ledgersmb-data -p 127.0.0.1:80:80 duelafn/ledgersmb:latest

On first run, some directories will be created and sampel configuration
files will be copied (if not already present). Configs may be modified and
will nto be overwritten.

Database setup:

    docker run --rm -h ledger.example.com -v /srv/ledgersmb/data:/opt/postgresql --name ledgersmb-data  duelafn/postgresql:latest

    docker exec -it ledgersmb-data sudo -u postgres createuser -s -l -I -P ledgersmb
    docker exec -it ledgersmb-data sudo -u postgres createdb -O ledgersmb ledgersmb


Volume Layout
=============

VOLUME: /www

* etc - site.conf apache configuration; ledgersmb.conf
* log - apache logs
* spool - ledgersmb process queue
* templates - template path


Docker Scripts
==============

    docker run  ... /docker/run
    docker exec ... /docker/reload
    docker exec ... /docker/stop
