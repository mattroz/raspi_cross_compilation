#/bin/bash

#	get current module name from the absolute path
MODULE_PATH=$1  #"${PWD##*/}"
#echo $MODULE_NAME

cd $MODULE_PATH
/usr/local/qt5pi/bin/qmake .
make -j$(nproc --all)
sudo make install
