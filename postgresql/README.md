
Volume Initialization
=====================

VOLUME: /opt/...


If you wish to export the postgres socket to a non-standard location, set
the `unix_socket_directories` to the non standard location in addition to
its default value. For example:

    unix_socket_directories = '/var/run/postgresql,/opt/postgres/sock'
