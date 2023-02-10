#!/bin/sh
set -e

ARCHITECTURE_NAME=amd64
ARCHITECTURE_BINARY=binary-amd64
SUITE=stable
COMPONENT=main
TARGET=docs

mkdir -p $TARGET/dists/${SUITE}/${COMPONENT}/${ARCHITECTURE_BINARY}
(cd $TARGET && dpkg-scanpackages --arch ${ARCHITECTURE_NAME} pool/ >dists/${SUITE}/${COMPONENT}/${ARCHITECTURE_BINARY}/Packages)
(cd $TARGET && dpkg-scanpackages --arch ${ARCHITECTURE_NAME} pool/ | gzip -9 >dists/${SUITE}/${COMPONENT}/${ARCHITECTURE_BINARY}/Packages.gz)
(cd $TARGET && dpkg-scanpackages --arch ${ARCHITECTURE_NAME} pool/ | bzip2 >dists/${SUITE}/${COMPONENT}/${ARCHITECTURE_BINARY}/Packages.bz2)

RELEASE_FILE1=$TARGET/dists/${SUITE}/Release
RELEASE_FILE2=$TARGET/dists/${SUITE}/${COMPONENT}/${ARCHITECTURE_BINARY}/Release
(./bin/generate-release-header.sh >$RELEASE_FILE1)
(./bin/generate-release-header.sh >$RELEASE_FILE2)

G=$(realpath ./bin/generate-release-files.sh)
(cd $TARGET/dists/${SUITE} && ${G} >>Release)

GNUPGHOME="$(mktemp -d)"
export GNUPGHOME

echo "$GPG_PRIVATE_KEY" | base64 -d | gpg --import
gpg --list-keys

cat $RELEASE_FILE1 | gpg --default-key "$GPG_KEY_NAME" -abs  >$RELEASE_FILE1.gpg
cat $RELEASE_FILE2 | gpg --default-key "$GPG_KEY_NAME" -abs  >$RELEASE_FILE2.gpg

cat $RELEASE_FILE1 | gpg --default-key "$GPG_KEY_NAME" -abs --clearsign  >$TARGET/dists/${SUITE}/InRelease
