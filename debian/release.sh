#!/bin/bash
#
# Maintainer script for publishing releases.

set -e

source=$(dpkg-parsechangelog -S Source)
version=$(dpkg-parsechangelog -S Version)
distribution=$(dpkg-parsechangelog -S Distribution)

OS=debian DIST=${distribution} ARCH=armel pbuilder-ev3dev build

debsign ~/pbuilder-ev3dev/debian/${distribution}-armel/${source}_${version}_armel.changes

dput ev3dev-debian ~/pbuilder-ev3dev/debian/${distribution}-armel/${source}_${version}_armel.changes

gbp buildpackage --git-tag-only
