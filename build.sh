#!/bin/bash
set -eu
cd "$(dirname "$0")"
find src -type d -exec chmod 0755 {} +
chmod 0755 src/DEBIAN/preinst src/DEBIAN/postrm src/usr/bin/tmog-task-manager src/usr/libexec/tmog-rapl-gate/rapl-gate
chmod 0644 src/DEBIAN/control src/usr/share/polkit-1/actions/*.policy src/usr/share/doc/tmog-rapl-gate/copyright
v=$(awk '/^Version:/ {print $2}' src/DEBIAN/control)
dpkg-deb --root-owner-group -Zxz --build src "tmog-rapl-gate_${v}_all.deb"
