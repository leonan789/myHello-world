#!/bin/bash
# ****************************************************************************
# Function:     SDcard partition:1."/boot" store initrd.gz 2."/" store squashfs
# Description:  SDcard divide in two part. One is "/boot" store initrd.gz, another is "/" store squashfs.
# Date:         2018/08/07
# Author:       nanweijia
# Input:        1.Path include xxx.iso and initrd.gz
#               2.SDcard fullname(e.g:/dev/xxx)
# ****************************************************************************

# ************************Variable*********************************************
IMG_FILE_DIR=$1
DEV_NAME=$2
TMPDIR_SD_MOUNT="sd_mount_dir"

if [ $(id -u) -ne 0 ];then
   echo "Please change to root user" 
   exit 1
fi
# end

# ************************EXE Output******************************************
shprint()
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
    shprint "ERROE" "$IMG_FILE_DIR is not exist"
    exit 1
fi

if [ ! -b "$DEV_NAME" ];then
    shprint "ERROE" "$DEV_NAME is not a block device file"
    exit 1
fi
# end

# ************************SDcard format prompt**********************************
shprint "WARNING" "Device $DEV_NAME will be formatted."
read -p "Do you want to continue <Y/N>?" answer

case $answer in
Y|y)
    echo -e "\033[36mStart formatting SDcard\033[0m";;
N|n)
    echo -e "\033[31mExit operation \033[0m";
    exit 1;;
*)  echo -e "\033[31mPlease reexecution the script\033[0m";exit 1;;
esac


if [ `ls -1 $DEV_NAME* | wc -l` -gt 1 ];then
    for i in `ls -1 $DEV_NAME*`; do
        echo "d
        w" | fdisk $DEV_NAME
        echo "$DEV_NAME number $SUM, $i"
    done
fi
umount $DEV_NAME 2>/dev/null

#echo "n



#+256M
#w" | fdisk $DEV_NAME
echo "n




w" | fdisk $DEV_NAME

#mkfs.ext4 -L boot ${DEV_NAME}1
#mkfs.ext4 -L ubuntu_fs ${DEV_NAME}2
mkfs.ext4 -L ubuntu_fs ${DEV_NAME}1
# end

# ************************Copy file to SDcard***********************************
if [ ! -d "$TMPDIR_SD_MOUNT"];then
    mkdir $TMPDIR_SD_MOUNT
fi

mount ${DEV_NAME}1 $TMPDIR_SD_MOUNT
cp ${IMG_FILE_DIR}/ubuntu_fs $TMPDIR_SD_MOUNT
if [ $? -ne 0 ];then
    shprint "ERROR" "Copy ubuntu_fs to SDcard failed"
    exit 1
else
    shprint "INFO" "Copy ubuntu_fs to SDcard Success"
fi
umount $TMPDIR_SD_MOUNT
# end
