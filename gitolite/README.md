
Volume Initialization
=====================

* Copy your administrative public key to your volume (suppose it is called admin-pk.pub).

* Run the gitolite setup with volume in place and various variables set.

    docker run --rm -it                  \
        -v /srv/git:/opt/git             \
        -u git -e USER=git gitolite      \
        gitolite setup -pk admin-pk.pub


* Create a folder "ssh_server" in the volume and copy your sshd_config to this folder.

Upon first boot ssh keys will be generated in the ssh_server folder. Keep
these keys safe!
