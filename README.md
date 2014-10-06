brickman
========

The ev3dev Brick Manager.

Issues
------

Please report issues or feature requests at https://github.com/ev3dev/ev3dev/issues

Hacking
-------

Things you need:
* Clone of the brickman repo.
* Install the build-deps in `debian/control`.
* For building the desktop test you also need to install `libgtk-3-dev`.

To build for the EV3:
* [Setup brickstrap]
* In `brickstrap shell`:

        sudo apt-get build-dep brickman
        mkdir -p /host-rootfs/<some-path-like-home/user/build-brickman>
        cd /host-rootfs/<some-path-like-home/user/build-brickman>
        cmake /host-rootfs/<path-to-brickman-repo> -DCMAKE_BUILD_TYPE=Debug
        make

* On your host computer (not in `brickstrap shell`), use NFS or sshfs to share
<some-path-like-home/user/build-brickman> with your EV3.
* On your EV3, connect the share and run `./brickman`

To build the desktop test (makes UI development much faster):
* Make sure you have installed the build-deps above, then...

        mkdir -p <some-build-dir>
        cd <some-build-dir>
        cmake <path-to-brickdm-source> -DCMAKE_BUILD_TYPE=Debug -DBRICKMAN_TEST=1
        make
        make run

* Also see `brickman.sublime-project` for more build hints.

Note: `brickman.sublime-project` is for [Sublime Text].

[Setup brickstrap]: https://github.com/ev3dev/ev3dev/wiki/Using-brickstrap-to-cross-compile-and-debug
[Sublime Text]: http://www.sublimetext.com/
