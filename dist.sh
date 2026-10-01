#!/bin/sh

#
# This shell script builds tnylpo and tnylpo-convert and packs them
# together with the documentation and the mine example into a zip archive.
# Under Cygwin, the archive additionally contains the required DLLs and
# a minimal terminfo database, so it can be used on Windows machines
# without a Cygwin installation.
#
# Usage: sh dist.sh [ <archive name> | clean ]
#
#	<archive name>	name of the zip archive without .zip
#			(default: tnylpo-<OS>)
#	clean		remove the dist directory and all zip archives
#
# Additional compiler and linker options (e.g. "-arch arm64 -arch x86_64"
# for a universal binary under Mac OS X) can be passed in the environment
# variables CPPFLAGS and LDFLAGS.
#

OS=`uname -s`
NAME="$1"
test -z "$NAME" && NAME="tnylpo-$OS"

if test "$NAME" = "clean"; then
	rm -rf dist tnylpo-*.zip
	exit 0
fi

set -e
case "$OS" in
CYGWIN*)
	#
	# build.sh does not support Cygwin, so build directly
	#
	make -f makefile.mk all CC="cc" \
	    CFLAGS="-std=c99 -pedantic -O3 -Wall -D_POSIX_C_SOURCE=200112L \
	    -D_XOPEN_SOURCE_EXTENDED -D_FILE_OFFSET_BITS=64 \
	    -I /usr/include/ncursesw" \
	    LIBS="-lncursesw"
	;;
*)
	sh build.sh all
	;;
esac
rm -rf dist "$NAME.zip"
mkdir -p dist/doc
cp tnylpo tnylpo-convert dist
cp -r mine dist/mine
cp LICENSE dist/doc/TNYLPO_LICENSE
cp README.md tnylpo.1 tnylpo-convert.1 dist/doc
case "$OS" in
CYGWIN*)
	mkdir -p dist/terminfo
	for t in xterm-256color xterm cygwin ansi vt100; do
		infocmp -x $t > dist/$t.src
		tic -x -o dist/terminfo dist/$t.src
		rm dist/$t.src
	done
	#
	# all Cygwin DLLs the executables depend on (cygwin1.dll, ncurses, ...)
	#
	ldd tnylpo.exe tnylpo-convert.exe |
	    awk '$3 ~ /^\/usr\/bin\// { print $3 }' | sort -u |
	    xargs cp -t dist
	cp /usr/share/doc/Cygwin/COPYING dist/doc/CYGWIN_LICENSE
	cp /usr/share/doc/Cygwin/CYGWIN_LICENSE dist/doc/CYGWIN_EXCEPTION
	cp /usr/share/doc/ncurses/COPYING dist/doc/NCURSES_LICENSE
	;;
esac
cd dist && zip -r "../$NAME.zip" .
