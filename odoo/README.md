
Volume Initialization
=====================

Set up data container:

    docker run --rm -h odoo-data -v /srv/odoo/data:/opt/postgresql --name odoo-data duelafn/postgresql:latest

    # Create odoo user with ability to create databases and a given password
    docker exec -it odoo-data sudo -u postgres createuser -d -P odoo

    echo "host   all   odoo   samenet   md5" | sudo tee -a data/conf/main/pg_hba.conf

    docker exec -it odoo-data /docker/reload

    docker run --rm -h odoo.utgllc.com -v /srv/odoo:/opt/odoo -p 127.0.0.1:8069:8069 -p 127.0.0.1:8071:8071 --link odoo-data:odoo-data --name odoo utgllc/odoo:latest


Volume Layout
=============

VOLUME: /opt/odoo


Docker Scripts
==============

    docker run  ... /docker/run
    docker exec ... /docker/stop
