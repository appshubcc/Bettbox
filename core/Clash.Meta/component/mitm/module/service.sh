#!/system/bin/sh
# Compatible KernelSU/Magisk/APatch CA injector.
# Copies system + APEX CAs, adds Bettbox CA, bind-mounts the result.
# Never mounts an empty directory.

MODDIR="${0%/*}"
LOG="/data/local/tmp/bettbox-ca.log"
WORK="$MODDIR/work"
CERT_SRC="$MODDIR/cacerts"
APEX="/apex/com.android.conscrypt/cacerts"
SYS="/system/etc/security/cacerts"

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') $*" >> "$LOG"
}

find_nsenter() {
  if command -v nsenter >/dev/null 2>&1; then
    echo "nsenter"
    return
  fi
  for b in /data/adb/ksu/bin/busybox /data/adb/magisk/busybox /data/adb/ap/bin/busybox /data/adb/ksunext/bin/busybox; do
    if [ -x "$b" ]; then
      echo "$b nsenter"
      return
    fi
  done
  echo ""
}

NSENTER="$(find_nsenter)"
SDK="$(getprop ro.build.version.sdk)"
[ -z "$SDK" ] && SDK=0

mkdir -p "$WORK"
# tmpfs so we never persist a partial copy over the real store
mountpoint -q "$WORK" || mount -t tmpfs -o mode=755 tmpfs "$WORK" || {
  log "tmpfs mount failed"
  exit 0
}

# Copy existing stores first. Abort if the result is too small.
if [ -d "$APEX" ]; then
  cp -f "$APEX"/* "$WORK/" 2>/dev/null
fi
if [ -d "$SYS" ]; then
  cp -f "$SYS"/* "$WORK/" 2>/dev/null
fi
if [ -d "$CERT_SRC" ]; then
  cp -f "$CERT_SRC"/* "$WORK/" 2>/dev/null
fi

COUNT="$(ls -1 "$WORK" 2>/dev/null | wc -l | tr -d ' ')"
if [ -z "$COUNT" ] || [ "$COUNT" -lt 10 ]; then
  log "abort: too few certificates in work dir ($COUNT)"
  umount "$WORK" 2>/dev/null
  exit 0
fi

chmod 644 "$WORK"/* 2>/dev/null
chown root:root "$WORK"/* 2>/dev/null
chcon u:object_r:system_security_cacerts_file:s0 "$WORK"/* 2>/dev/null \
  || chcon u:object_r:system_file:s0 "$WORK"/* 2>/dev/null

if [ -d "$SYS" ]; then
  mount --bind "$WORK" "$SYS"
  log "bound $WORK -> $SYS ($COUNT certs)"
fi

inject_pid() {
  pid="$1"
  [ -n "$pid" ] || return 0
  [ -d "/proc/$pid/ns/mnt" ] || return 0
  [ -n "$NSENTER" ] || return 0
  $NSENTER --mount="/proc/$pid/ns/mnt" -- mount --bind "$WORK" "$APEX" 2>/dev/null
}

inject_apex() {
  [ "$SDK" -ge 34 ] || return 0
  [ -d "$APEX" ] || return 0
  [ -n "$NSENTER" ] || {
    log "nsenter not found; skip APEX inject"
    return 0
  }
  inject_pid 1
  for p in $(pidof zygote 2>/dev/null); do inject_pid "$p"; done
  for p in $(pidof zygote64 2>/dev/null); do inject_pid "$p"; done
  for pid in /proc/[0-9]*; do
    pid="${pid##*/}"
    if [ -d "/proc/$pid/root$APEX" ] || [ -d "/proc/$pid/root/apex/com.android.conscrypt/cacerts" ]; then
      inject_pid "$pid"
    fi
  done
  log "APEX inject attempted (sdk=$SDK nsenter=$NSENTER)"
}

wait_zygote() {
  i=0
  while [ "$i" -lt 20 ]; do
    if pidof zygote >/dev/null 2>&1 || pidof zygote64 >/dev/null 2>&1; then
      return 0
    fi
    sleep 1
    i=$((i + 1))
  done
}

wait_zygote
inject_apex

# Re-inject for a short window in case zygote restarts during late boot.
(
  i=0
  while [ "$i" -lt 15 ]; do
    sleep 2
    inject_apex
    i=$((i + 1))
  done
) &

exit 0
