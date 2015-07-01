#!/usr/bin/env bash

#test.sh
#
# 

ruta = ~/Dev/servers/vagrant-setup/
file = test.sh

if [ -f $ruta $file ]; then
	echo "hola si que existo"
else
	echo "no existo"
fi
