#!/bin/sh

#
# This shell script builds tnylpo and tnylpo-convert and packs them
# together with the documentation and the mine example into a zip archive.
# Under Cygwin, the archive additionally contains the required DLLs and
# a minimal terminfo database, so it can be used on Windows machines
# without a Cygwin installation.
#
# Usage: sh dist.sh
#

OS=`uname -s`
case "$OS" in
CYGWIN*)
	#
	# build.sh does not support Cygwin, so build directly
	#
	make -f makefile.mk all CC="cc" \
	    CFLAGS="-std=c99 -pedantic -O3 -Wall -D_POSIX_C_SOURCE=200112L \
	    -D_XOPEN_SOURCE_EXTENDED -D_FILE_OFFSET_BITS=64 \
	    -I /usr/include/ncursesw" \
	    LIBS="-lncursesw" || exit 1
	;;
*)
	sh build.sh all || exit 1
	;;
esac
mkdir -p dist/doc
cp tnylpo dist
cp tnylpo-convert dist
cp -r mine dist/mine
cp LICENSE dist/doc/TNYLPO_LICENSE
case "$OS" in
CYGWIN*)
	mkdir -p dist/terminfo
	for t in xterm-256color xterm cygwin ansi vt100; do
		infocmp $t > $t.src
		tic -x -o dist/terminfo $t.src
	done
	cp /usr/bin/cygwin1.dll dist
	cp /usr/bin/cygncursesw-10.dll dist
	cp /usr/share/doc/Cygwin/COPYING dist/doc/CYGWIN_LICENSE
	cp /usr/share/doc/Cygwin/CYGWIN_LICENSE dist/doc/CYGWIN_EXCEPTION
	cp /usr/share/doc/ncurses/COPYING dist/doc/NCURSES_LICENSE
	;;
esac
cd dist; zip -r ../tnylpo-$OS.zip *; cd ..
