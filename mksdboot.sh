#! /bin/sh
#usage mksdboot.sh --device /dev/sdb

VERSION="0.1"

execute ()
{
    $* >/dev/null
    if [ $? -ne 0 ]; then
        echo
        echo "ERROR: executing $*"
        echo
        exit 1
    fi
}

version ()
{
  echo
  echo "`basename $1` version $VERSION"
  echo

  exit 0
}

usage ()
{
  echo "
Usage: `basename $1` <options> [ files for install partition ]

Mandatory options:
  --device              SD block device node (e.g /dev/sdd)

Optional options:
  --version             Print version.
  --help                Print this help message.
"
  exit 1
}

# Process command line...
while [ $# -gt 0 ]; do
  case $1 in
    --help | -h)
      usage $0
      ;;
    --device) shift; device=$1; shift; ;;
    --version) version $0;;
    *) copy="$copy $1"; shift; ;;
  esac
done

test -z $device && usage $0


 
if [ ! -b $device ]; then
   echo "ERROR: $device is not a block device file"
   exit 1;
fi

echo "************************************************************"
echo "*         THIS WILL DELETE ALL THE DATA ON $device        *"
echo "*                                                          *"
echo "*         WARNING! Make sure your computer does not go     *"
echo "*                  in to idle mode while this script is    *"
echo "*                  running. The script will complete,      *"
echo "*                  but your SD card may be corrupted.      *"
echo "*                                                          *"
echo "*         Press <ENTER> to confirm....                     *"
echo "************************************************************"
read junk

for i in `ls -1 $device?`; do
 echo "unmounting device '$i'"
 umount $i 2>/dev/null
done

execute "dd if=/dev/zero of=$device bs=1024 count=1024"

# get the partition information.
total_size=`fdisk -l $device | grep Disk | awk '{print $5}'`
total_cyln=`echo $total_size/255/63/512 | bc`

# default number of cylinder for first parition
pc1=5
# calculate number of cylinder for the second parition
if [ "$copy" != "" ]; then
# installer on one 4GB SD card.
#  pc2=110
pc2=$((($total_cyln - $pc1) / 2))
fi

# pc2=$((($total_cyln - $pc1) / 2))

#{
#echo ,$pc1,0x0C,*
#if [ "$pc2" != "" ]; then
# echo ,$pc2,,-
# echo ,,,-
#else
# echo ,,,-
#fi
#} | sfdisk -D -H 255 -S 63 -C $total_cyln $device

{
    echo ,144585,0x0C,*
    echo ,,,-
} | sfdisk $device

if [ $? -ne 0 ]; then
    echo ERROR
    exit 1;
fi

echo "Formating ${device}1 ..."
execute "mkfs.vfat -F 32 -n "boot" ${device}1"
echo "Formating ${device}2 ..."
#execute "mkfs.ext3 -j -L "ROOTFS" ${device}2"
execute "mkfs.ext4 -j -L "rootfs" ${device}2"
if [ "$pc2" != "" ]; then
 echo "Formating ${device}3 ..."
 execute "mkfs.ext3 -j -L "START_HERE" ${device}3"
fi

execute "export ZN_SCRIPT_DIR="$(cd $(dirname "$0") && pwd)""
BOOT_MOUNT_POINT=/tmp/sdk/boot
ROOT_MOUNT_POINT=/tmp/sdk/rootfs

execute "mkdir -p ${BOOT_MOUNT_POINT} ${ROOT_MOUNT_POINT}"

echo "mount the boot partition to ${BOOT_MOUNT_POINT}"
execute "mount -t vfat ${device}1 ${BOOT_MOUNT_POINT}"
echo "Install boot images to ${BOOT_MOUNT_POINT}"
execute "cp -rf ${ZN_SCRIPT_DIR}/boot/* ${BOOT_MOUNT_POINT}"
sync
echo "umount the boot partition from ${BOOT_MOUNT_POINT}"
execute "umount ${BOOT_MOUNT_POINT}"

echo "mount the rootfs partition to ${ROOT_MOUNT_POINT}"
execute "mount -t ext4 ${device}2 ${ROOT_MOUNT_POINT}"
echo "Install rootfs images to ${ROOT_MOUNT_POINT}"
execute "tar zxf ${ZN_SCRIPT_DIR}/rootfs/olympus_rootfs.tar.gz -C ${ROOT_MOUNT_POINT}"
sync
echo "umount the rootfs partition from ${ROOT_MOUNT_POINT}"
execute "umount ${ROOT_MOUNT_POINT}"

execute "rm -rf ${BOOT_MOUNT_POINT} ${ROOT_MOUNT_POINT}"

echo "completed!" 
