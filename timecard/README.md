
Volume Initialization
=====================

VOLUME: /opt/timeclock

Create a suitable HTTP (no ssl if you are using nginx reverse proxy)
configureation in etc/apache2/timeclock.conf

Clone a copy of https://github.com/duelafn/timeclock to the www directory
(/opt/timeclock/www/index.php should exist).


Linked Containers
=================

Create a mariadb instance named tineclock-data.


Host Configuration
==================

Unless the site is directly exposed, create an nginx reverse proxy on the
host. Example:

    server {
        listen *:80;
        server_name timeclock.apcillc.com timeclock.machinemotion.com www.timeclock.machinemotion.com www.timeclock.apcillc.com;
        return  301 https://$server_name$request_uri;
    }

    server {
        listen 162.17.32.4:443;
        server_name timeclock.apcillc.com timeclock.machinemotion.com www.timeclock.machinemotion.com www.timeclock.apcillc.com;

        ssl on;
        ssl_certificate /opt/timeclock/etc/apache2/ssl/timeclock.apcillc.com.chained.crt;
        ssl_certificate_key /opt/timeclock/etc/apache2/ssl/timeclock.apcillc.com.key;
        ssl_session_cache shared:SSL:10m;

        location / {
            proxy_pass http://localhost:3880; # my existing apache instance
            proxy_set_header Host $host;

            # re-write redirects to http as to https, example: /home
            proxy_redirect http:// https://;
        }
    }
