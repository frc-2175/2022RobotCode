#!/bin/bash

set -euo pipefail

LUAJIT_TMP=/tmp/luajitbuild
rm -rf $LUAJIT_TMP

pushd lib/LuaJIT-2.1
	# build
	make
	
	# copy all the stuff to the place
	make install PREFIX=$LUAJIT_TMP
popd

function install() {
	pushd $LUAJIT_TMP/lib
	for filename in $1; do mv "$filename" "${filename%.*}_linux.${filename##*.}"; done
	popd
	cp $LUAJIT_TMP/lib/$1 lib
}

# install in lib folder
install *.a
install *.so
