#!/bin/bash

################################################################################
# Generate Hash code
# Arguments:
#   hash_name: name of hash
#   hash_command: command to generate the hash
# Outputs:
#   Printout hash code info for each file
################################################################################
do_hash() {
  local hash_name hash_command
  hash_name=$1
  hash_command=$2
  echo "${hash_name}:"
  find . -type f | while read -r filename; do
    filename=$(echo "$filename" | cut -c3-) # remove ./ prefix
    if [ "$filename" != "Release" ]; then
      echo " $(${hash_command} "${filename}" | cut -d" " -f1) $(wc -c "$filename")"
    fi
  done
}

set -e
do_hash "MD5Sum" "md5sum"
do_hash "SHA1" "sha1sum"
do_hash "SHA256" "sha256sum"
