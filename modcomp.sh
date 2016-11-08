#/bin/bash

#	check arguments number
if [ "$#" -ne 1 ]; then
	echo "error: missing path to module (./modprobe path/to/module)"
	exit 1
fi

#	get current module path
MODULE_PATH=$1  #"${PWD##*/}"

cd $MODULE_PATH
/usr/local/qt5pi/bin/qmake .
make -j$(nproc --all)
sudo make install
