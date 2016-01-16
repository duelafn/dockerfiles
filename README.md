
Usage
=====

Volumes
=======

These dockerfiles are set up to use a single volume for both configuration
and perminant storage. Contrary to recommended practices, I typically mount
plain directory volumes rather than use storage containers, so that is what
all the samples use. Feel free to use storage containers if you like.


Creating New Machines
=====================

Directory Template:

    Dockerfile.in
    Makefile
    README.md
    docker/
    ├── init
    ├── reload
    ├── run
    ├── stop
    └── upgrade

Nothing is just a simple copy/paste, most everything needs revised for a
new project.

Most `Dockerfile.in` should end with `CMD exec /docker/run` and the docker
commands `reload` and `stop` are highly recommended and should perform
actions appropriate for the corresponding systemd commands.

The `/docker/init` script should generally only be used if there is
initialization which requires user interaction or otherwise is not safe to
test for on each startup. Thus, most initialization should really occur in
`/docker/run`, including initialization of reasonable config files (if
absent) and creation of any required directories (alas, we can't use
`tmpfiles.d`).

The `/docker/upgrade` script should be able to upgrade the data storage to
the most recent (or otherwise specially tagged) version. It does not
upgrade the container itself, that would be silly.
