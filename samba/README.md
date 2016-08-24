
Volume Initialization
=====================

Just run container. Creates a configuration in
`$VOLUME/etc/smb.conf.d/00_default.conf` from the default Debian config.

Configuration is read from the first available of:

  1. Concatenation of all files in `$VOLUME/etc/smb.conf.d`

  2. `$VOLUME/etc/smb.conf`

  3. The default Debian configuration (will additionally be copied to
     `$VOLUME/etc/smb.conf.d/00_default.conf` and therefore used on next
     boot).

If you want nmbd name resolution to work, you need to use `--net host` in
your docker run command, though note the security issues with that!


Volume Layout
=============

VOLUME: /opt/samba

The configuration files are described above.

    VOLUME/etc/smb.conf.d/

Users are preserved in the volume group, passwd, and shadow files. They
will be merged into the system files at startup.

    VOLUME/etc/group
    VOLUME/etc/passwd
    VOLUME/etc/shadow

Samba's password database could be anything, but the `adduser` and `passwd`
scripts in `/docker` will only modify `VOLUME/etc/passdb.tdb`.

    VOLUME/etc/passdb.tdb

Logs are saved to the log directory.

    VOLUME/log/


Docker Scripts
==============

    docker run  ... /docker/run
    docker exec ... /docker/stop

If you would like to use simple tdb-based user management, the following
scripts will edit the password database and the system group, passwd, and
shadow files.

    docker exec ... /docker/adduser
    docker exec ... /docker/passwd
