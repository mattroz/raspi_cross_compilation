#!/bin/bash

#####################################
#                                   #
#  CROSS-COMPILATION FOR RASPBERRY  #
#                                   #
#####################################

XCOMP_DIR=~/raspi_cross
MNT_DIR=/mnt/rasp-pi-rootfs/
RASPBIAN_IMG_NAME=2016-09-23-raspbian-jessie.img


#	First step: make directory @ home
echo -e "\nCREATING DIRECTORY $XCOMP_DIR"
mkdir $XCOMP_DIR

######################################
#   mount image to mount directory   #
######################################
cd $XCOMP_DIR
echo -e "\nDOWNLOADING RASPBERRY IMAGE TO $XCOMP_DIR\n"
wget http://director.downloads.raspberrypi.org/raspbian/images/raspbian-2016-09-28/2016-09-23-raspbian-jessie.zip

echo -e "\nUNZIPPING RASPBERRY IMAGE TO $XCOMP_DIR\n"
unzip -jq "${RASPBIAN_IMG_NAME::-4}.zip"

#	calculate offset for mounting
RASP_IMG_OFFSET="$((512*$(sudo fdisk -l $XCOMP_DIR/$RASPBIAN_IMG_NAME | tail -n1 | grep -E -o '\s{1,}[0-9]*' | head -n1)))"

echo -e "\nMOUNTING RASPBERRY IMAGE AT $MNT_DIR\n"
sudo mkdir $MNT_DIR
sudo mount -o loop,offset=$RASP_IMG_OFFSET $XCOMP_DIR/$RASPBIAN_IMG_NAME $MNT_DIR

sudo umount $MNT_DIR 
rm -rf $XCOMP_DIR
exit 1					#for debugging


#####################################################
#   clone Qt5 sources and go to created directory   #
#####################################################
cd $XCOMP_DIR
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
#   git installation and cross compilation tools cloning      #
###############################################################
sudo apt-get install git
cd $XCOMP_DIR
git clone https://github.com/darius-kim/cross-compile-tools.git
cd $XCOMP_DIR/cross-compile-tools
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

############################################
#          make and install Qt             #
############################################
make -j$(nproc --all)
sudo make install



