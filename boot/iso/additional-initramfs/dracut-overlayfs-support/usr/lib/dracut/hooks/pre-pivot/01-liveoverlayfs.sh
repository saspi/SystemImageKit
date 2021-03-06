# https://github.com/haraldh/dracut/issues/104
# After the live system has been mounted using the usual dracut dmsquash way,
# we actually change things to use overlayfs and tmpfs instead.
# This is a bit hackish and should be integrated properly into dmsquash instead.

# Mount the overlayfs kernel module from inside the Live system
# since the kernel module is missing in the initrd. This is why we use this
# script in addition to, rather than instead of, dmsquash. (FIXME)

modprobe -d /sysroot overlay

if [ $? -eq 0 ] && [ ! -e /etc/mageia-release ] ; then

# Now we do not need the sysroot provided by dmsquash any longer
umount -lf /sysroot

mkdir /run/sysroot

# Mount the squashfs image and the filesystem image therein
# TODO: do not hardcode the names
# but rather do it similar to /sbin/dmsquash-live-root.sh
mount /run/initramfs/live/LiveOS/squashfs.img /run/initramfs/squashfs

# F23-
if [ -e /run/initramfs/squashfs/LiveOS/ext3fs.img ] ; then
  mount /run/initramfs/squashfs/LiveOS/ext3fs.img /run/sysroot
fi
# F24+
if [ -e /run/initramfs/squashfs/LiveOS/rootfs.img ] ; then
  mount /run/initramfs/squashfs/LiveOS/rootfs.img /run/sysroot
fi

# Use overlayfs to mount /run "over" the root filesystem coming from the Live ISO
# TODO: Could mount additional lowerdirs
mkdir -p /run/upper
mkdir -p /run/work
mount -t overlay -o lowerdir=/run/sysroot,upperdir=/run/upper,workdir=/run/work overlay "${NEWROOT}"

else
  # Next command needs to succeed so that older ISOs can still be booted
  echo "Overlayfs filesystem not available"
fi

