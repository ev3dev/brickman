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

*   Install [Docker] (requires Linux/macOS 10.10.3+/Window 10 Pro)
*   Install QEMU (Linux only)

        sudo apt-get install qemu-user-static

*   In the source code directory, run the Docker setup script

        ./docker/setup.sh $ARCH

    Where `$ARCH` is `armel` (or `armhf` if you are building for RPi
    or BeagleBone).  Output will be saved to a `build-$ARCH` directory.

*   Build the code by running...

        docker exec --tty brickman_armel make install

*   Copy the contents of `build-$ARCH/dist/` to the EV3 and run it.

[Docker]: https://www.docker.com/

To build the desktop test (makes UI development much faster), in a regular terminal,
not in Docker:

*   Install build dependancies:

        sudo apt-add-repository ppa:ev3dev/tools
        sudo apt-get update
        sudo apt-get install devscripts equivs
        sudo mk-build-deps --install debian/control

* Then...

        mkdir -p <some-build-dir>
        cd <some-build-dir>
        cmake <path-to-brickdm-source> -DCMAKE_BUILD_TYPE=string:Debug -DBRICKMAN_TEST=bool:Yes
        make
        make run
