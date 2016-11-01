#!/bin/bash

###################################
#                                 #
#	X-COMPILATION FOR RASPBERRY   #
#								  #
###################################


XCOMP_DIR=~/raspi_cross
MNT_DIR=/mnt/rasp-pi-rootfs/
RASPBIAN_IMG_NAME=2016-09-23-raspbian-jessie.img
RASP_IMG_OFFSET="$((512*$(sudo fdisk -l $XCOMP_DIR/$RASPBIAN_IMG_NAME | tail -n1 | grep -E -o '\s{1,}[0-9]*' | head -n1)))"


#	First step: make directory @ home
mkdir $(XCOMP_DIR)
#echo $XCOMP_DIR

#echo "$RASP_IMG_OFFSET"

#	mount image to mount dir
sudo mount -o loop,offset="$RASP_IMG_OFFSET" "$XCOMP_DIR/$RASPBIAN_IMG_NAME" "$MNT_DIR"

#	clone Qt5 sources and go to created directory
git clone git://code.qt.io/qt/qt5.git
cd qt5


#	init all submodules, repositories, etc
./init-repository
