#!/system/bin/sh
MODDIR="${0%/*}"
umount "$MODDIR/work" 2>/dev/null
rm -rf "$MODDIR/work"
exit 0
