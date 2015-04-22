
Volume Initialization
=====================

Just run the image. An `etc/ssh` folder will be created and initilized with
default debian contents.

Edit `etc/ssh/sshd_config` and/or add users and groups to `etc/passwd`
`etc/shadow` `etc/group` (in the volume). They will be picked up the next
time the container is run, or else execute:

    docker exec -it sshd /docker/reload

User home directories should be placed in the volume if their contents are
to be preserved.
