#!/bin/bash

#####################################
#                                   #
#  CROSS-COMPILATION FOR RASPBERRY  #
#                                   #
#####################################

XCOMP_DIR=~/raspi_cross
MNT_DIR=/mnt/rasp-pi-rootfs/
RASPBIAN_IMG_NAME=2016-09-23-raspbian-jessie.img
#echo $RASPBIAN_IMG_NAME
RASP_IMG_OFFSET="$((512*$(sudo fdisk -l $(pwd)/images/$RASPBIAN_IMG_NAME | tail -n1 | grep -E -o '\s{1,}[0-9]*' | head -n1)))"


#	First step: make directory @ home
echo -e "\nCREATING DIRECTORY $XCOMP_DIR"
mkdir $XCOMP_DIR

######################################
#   mount image to mount directory   #
######################################
echo -e "\nCOPYING RASPBERRY IMAGE TO $XCOMP_DIR\n"
cp $(pwd)/images/$RASPBIAN_IMG_NAME $XCOMP_DIR
echo -e "\nMOUNTING RASPBERRY IMAGE AT $MNT_DIR\n"
cd $XCOMP_DIR
sudo mount -o loop,offset="$RASP_IMG_OFFSET" "$RASPBIAN_IMG_NAME" "$MNT_DIR"

#####################################################
#   clone Qt5 sources and go to created directory   #
#####################################################
echo -e "\nCLONING QT5 TO $XCOMP_DIR\n"
git clone git://code.qt.io/qt/qt5.git
cd qt5

##############################################
#   init all submodules, repositories, etc   #
##############################################
echo -e "\nINITIALIZING QT DIRECTORY\n"
./init-repository

#######################################################
#   get toolchain for cross-compilation and unzip it  #
#######################################################
echo -e "\nTOOLCHAIN DOWNLOADING\n"
cd $XCOMP_DIR
wget https://www.dropbox.com/s/sl919ly0q79m1e6/gcc-4.7-linaro-rpi-gnueabihf.tbz
echo -e "\nTOOLCHAIN UNZIPPING\n"
tar xfj gcc-4.7-linaro-rpi-gnueabihf.tbz

###############################################################
#   add git installation and cross compilation tools cloning  #
###############################################################
sudo apt-get install git
git clone https://github.com/darius-kim/cross-compile-tools.git
cd cross-compile-tools
sudo chmod a+x fixQualifiedLibraryPaths
./fixQualifiedLibraryPaths $MNT_DIR

#sudo umount $MNT_DIR 
#rm -rf $XCOMP_DIR
#exit 1					#for debugging

###############################################
#   configure Qt libs and tools for building  #
###############################################
cd $XCOMP_DIR/qt5/qtbase
./configure 
    -opengl es2 
    -device linux-rasp-pi-g++ 
    -device-option CROSS_COMPILE=$XCOMP_DIR/gcc-4.7-linaro-rpi-gnueabihf/bin/arm-linux-gnueabihf- 
    -sysroot /mnt/rasp-pi-rootfs 
    -opensource 
    -confirm-license 
    -optimized-qmake 
    -reduce-exports 
    -release 
    -make libs 
    -make tools
    -prefix /usr/local/qt5pi
    -hostprefix /usr/local/qt5pi

#	the second configuration variant
:`
./configure \
  -release \
  -opengl es2 \
  -optimized-qmake \
  -no-pch \
  -make libs \
  -make tools \
  #-reduce-relocations \
  -reduce-exports \
  -sysroot $MNT_DIR \
  -device linux-rasp-pi-g++ \
 -device-option CROSS_COMPILE=$XCOMP_DIR/gcc-4.7-linaro-rpi-gnueabihf/bin/arm-linux-gnueabihf- \ 
 -prefix /usr/local/Qt-5.0.2-raspberry
`
