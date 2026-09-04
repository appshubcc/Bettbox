#!/system/bin/sh
# Compatible mode: skip_mount is set. Actual bind mounts run in service.sh
# after zygote is available. This script only prepares the work directory.
MODDIR="${0%/*}"
mkdir -p "$MODDIR/work" "$MODDIR/cacerts"
exit 0
