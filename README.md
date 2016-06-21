brickman
========

The ev3dev Brick Manager.

Issues
------

Please report issues or feature requests at https://github.com/ev3dev/ev3dev/issues

Hacking
-------

Get the code:

* Clone of the brickman repo.

        git clone git://github.com/ev3dev/brickman
        cd brickman
        git submodule update --init --recursive

To build for the EV3:

* [Setup brickstrap]
* In `brickstrap shell`:

        sudo apt-get build-dep brickman
        mkdir -p /host-rootfs/<some-path-like-home/user/build-brickman>
        cd /host-rootfs/<some-path-like-home/user/build-brickman>
        cmake /host-rootfs/<path-to-brickman-repo> -DCMAKE_BUILD_TYPE=string:Debug
        make

* On your host computer (not in `brickstrap shell`), use NFS or sshfs to share
<some-path-like-home/user/build-brickman> with your EV3.
* On your EV3, stop the runing service: `sudo systemctl stop brickman`, connect
the share and run `./brickman` or if you temporarily replaced the one in
`/usr/sbin` restart it with `sudo systemctl start brickman`.
* If running brickman from systemd, you find the stdout/stderr in the journal:
`journalctl -f -u brickman`.
* To get more details you can `sudo systemctl set-environment G_MESSAGES_DEBUG=all` and `sudo systemctl restart brickman`.
* likewise you can tune down the amount of logging with `sudo systemctl unset-environment G_MESSAGES_DEBUG` followed by `sudo systemctl restart brickman`.

To build the desktop test (makes UI development much faster), in a regular terminal,
not in brickstrap shell:

* Install the build-deps listed in `debian/control` and also the packages
  `libev3devkit-desktop-dev` and `libgtk-3-dev`.
* Then...

        mkdir -p <some-build-dir>
        cd <some-build-dir>
        cmake <path-to-brickman-source> -DCMAKE_BUILD_TYPE=string:Debug -DBRICKMAN_TEST=bool:Yes
        make
        make run

* Also see `brickman.sublime-project` for more build hints.

Note: `brickman.sublime-project` is for [Sublime Text].

[Setup brickstrap]: https://github.com/ev3dev/ev3dev/wiki/Using-brickstrap-to-cross-compile-and-debug
[Sublime Text]: http://www.sublimetext.com/
