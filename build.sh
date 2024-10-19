#!/bin/bash

readonly ARCHITECTURE_NAME=amd64
readonly ARCHITECTURE_BINARY=binary-amd64
readonly SUITE=stable
readonly COMPONENT=main
readonly TARGET=docs
readonly architecture_path=dists/${SUITE}/${COMPONENT}/${ARCHITECTURE_BINARY}

set -e
mkdir -p -v "${TARGET}/$architecture_path"
(
  cd "${TARGET}" &&
    dpkg-scanpackages --arch "${ARCHITECTURE_NAME}" pool/ \
      >$architecture_path/Packages
)
(
  cd "${TARGET}" &&
    dpkg-scanpackages --arch "${ARCHITECTURE_NAME}" pool/ |
    gzip -9 >$architecture_path/Packages.gz
)
(
  cd "${TARGET}" &&
    dpkg-scanpackages --arch "${ARCHITECTURE_NAME}" pool/ |
    bzip2 >$architecture_path/Packages.bz2
)

readonly root_release_file=${TARGET}/dists/${SUITE}/Release
readonly architecture_release_file=${TARGET}/${architecture_path}/Release
(./bin/generate-release-header.sh >$root_release_file)
(./bin/generate-release-header.sh >$architecture_release_file)

generate_releaese_files_bin=$(realpath ./bin/generate-release-files.sh)
(cd ${TARGET}/dists/${SUITE} && ${generate_releaese_files_bin} >>Release)

GNUPGHOME="$(mktemp -d)"
readonly GNUPGHOME
export GNUPGHOME

echo "$GPG_PRIVATE_KEY" | base64 -d | gpg --import
gpg --list-keys

cat $root_release_file | gpg --default-key "$GPG_KEY_NAME" -abs >"${root_release_file}.gpg"
cat $architecture_release_file | gpg --default-key "$GPG_KEY_NAME" -abs >$architecture_release_file.gpg

cat $root_release_file | gpg --default-key "$GPG_KEY_NAME" -abs --clearsign >${TARGET}/dists/${SUITE}/InRelease
