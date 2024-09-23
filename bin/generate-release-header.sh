#!/bin/bash
set -e

cat <<EOF
Origin: Siak Hooi APT Repository
Suite: stable
Version: 1.0
Architectures: amd64
Components: main
Description: Siak Hooi APT Repository
Date: $(date -Ru)
EOF
