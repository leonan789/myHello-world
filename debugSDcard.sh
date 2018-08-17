#!/bin/bash
# *****************************************************************************
# Function:     SDcard fabrication
# Description:  SDcard format, decompress mini-ramfs.cpio.gz and copy "/" from $1 to SDcard.
# Date:         2018/08/15
# Author:       nanweijia
# Input:        1.Path include mini-ramfs.cpio.gz
#               2.SDcard fullname(e.g:/dev/xxx)
# *****************************************************************************

# ************************Variable*********************************************
IMG_FILE_DIR=$1
CPIO_FILE=$(ls $IMG_FILE_DIR/*cpio.gz 2>/dev/null)
DEV_NAME=$2
EXTRA_PARA=$3
TMPDIR_SD_MOUNT=sd_mount_dir

if [ $(id -u) -ne 0 ];then
   echo "Please change to root user" 
   exit 1
fi
# end

# ************************EXE Output******************************************
function shprint()
{
     level=$1
     msg=$2
     DATE=`date +"%F %X"`
     echo -e "${DATE}\\r\\n${level}: ${msg}"
}
# end

# ************************Check args*******************************************
if [ $# -ne 2 ];then
     shprint "ERROR para number" "Usage: $0 <img path> <dev fullname>!!!"
     exit 1;
fi
# end

# ************************Check the directory**********************************
if [ ! -d "$IMG_FILE_DIR" ];then
    shprint "ERROR" "$IMG_FILE_DIR is not exist"
    exit 1
fi

if [ `ls $IMG_FILE_DIR/*cpio.gz 2>/dev/null | wc -l` -ne 1 ];then
    shprint "ERROR" "Please put one cpio.gz file in $IMG_FILE_DIR!"
    exit 1
fi

if [ ! -b "$DEV_NAME" ];then
    shprint "ERROR" "$DEV_NAME is not a block device file"
    exit 1
fi
# end

# ************************SDcard format prompt**********************************
shprint "WARNING" "\033[33mDevice $DEV_NAME will be formatted and all date will be deleted!\033[0m"
read -p "Do you want to continue <Y/N>?" answer

case $answer in
Y|y)
    echo -e "\033[36mStart formatting SDcard\033[0m";;
N|n)
    echo -e "\033[31mExit operation \033[0m";
    exit 1;;
*)  echo -e "\033[31mInput illegal! Please execute the script again\033[0m";exit 1;;
esac

if [ `ls -1 $DEV_NAME* 2>/dev/null | wc -l` -gt 1 ];then
    for i in `ls -1 $DEV_NAME*`; do
        echo "d

        w" | fdisk $DEV_NAME
    done
fi
umount $DEV_NAME 2>/dev/null

echo "n




w" | fdisk $DEV_NAME

mkfs.ext4 -L ubuntu_fs ${DEV_NAME}1
# end

# ************************Decompress mini-ramfs.cpio.gz*************************
function cpioDecompress()
{
    gunzip -c $CPIO_FILE > ${TMPDIR_SD_MOUNT}/mini-ramfs.cpio
    pushd $TMPDIR_SD_MOUNT
    cpio -idmv < mini-ramfs.cpio
    rm mini-ramfs.cpio
    popd
    echo "file in $TMPDIR_SD_MOUNT:"
    ls $TMPDIR_SD_MOUNT
}

# ************************Copy file to SDcard***********************************
if [ -d "$TMPDIR_SD_MOUNT" ];then
    umount $TMPDIR_SD_MOUNT 2>/dev/null
    rm -rf $TMPDIR_SD_MOUNT
fi

mkdir $TMPDIR_SD_MOUNT
mount ${DEV_NAME}1 $TMPDIR_SD_MOUNT 2>/dev/null
cpioDecompress
#case $EXTRA_PARA in
#    CPIO)
#	cpioDecompress;;
#    IMG)exit 1;;
#    *)  exit 1;;
#esac

if [ $? -ne 0 ];then
    shprint "ERROR" "\033[31mCopy ubuntu_fs to SDcard failed\033[0m"
    exit 1
else
    shprint "INFO" "\033[32mCopy ubuntu_fs to SDcard Success\033[0m"
fi
umount $TMPDIR_SD_MOUNT 2>/dev/null
# end
