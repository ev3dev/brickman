#!/bin/bash
#
# Maintainer script for publishing releases.

set -e

source=$(dpkg-parsechangelog -S Source)
version=$(dpkg-parsechangelog -S Version)
distribution=$(dpkg-parsechangelog -S Distribution)
codename=$(debian-distro-info --codename --${distribution})

OS=debian DIST=${codename} ARCH=armhf pbuilder-ev3dev build
OS=debian DIST=${codename} ARCH=armel PBUILDER_OPTIONS="--binary-arch" pbuilder-ev3dev build
OS=raspbian DIST=${codename} ARCH=armhf pbuilder-ev3dev build

debsign ~/pbuilder-ev3dev/debian/${codename}-armhf/${source}_${version}_armhf.changes
debsign ~/pbuilder-ev3dev/debian/${codename}-armel/${source}_${version}_armel.changes
debsign ~/pbuilder-ev3dev/raspbian/${codename}-armhf/${source}_${version}_armhf.changes

dput ev3dev-debian ~/pbuilder-ev3dev/debian/${codename}-armhf/${source}_${version}_armhf.changes
dput ev3dev-debian ~/pbuilder-ev3dev/debian/${codename}-armel/${source}_${version}_armel.changes
dput ev3dev-raspbian ~/pbuilder-ev3dev/raspbian/${codename}-armhf/${source}_${version}_armhf.changes

gbp buildpackage --git-tag-only
