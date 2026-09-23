#!/bin/sh

# Copyright (c) 2026 Georg Brein. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright
#    notice ,this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# 3. Neither the name of the copyright holder nor the names of its
#    contributors may be used to endorse or promote products derived from
#    this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

#
# This shell script builds tnylpo and tnylpo-convert from the source code.
#
# Usage: sh build.sh [ <target> ]
#
# Valid <target>s are:
#	all		build tnylpo and tnylpo-convert (default)
#	tnylpo		build just tnylpo
#	tnylpo-convert	build just tnylpo-convert	
#	clean		remove object files left from an earlier build
#	veryclean	remove object files and binaries
#

#
# if no explicit target is passed to build.sh, "all" is assumed
#
TARGET="$1"
test -z "$TARGET" && TARGET="all"

#
# determine platform specific parameters and options for the build process
#
OS=`uname -s`
case "$OS" in
Linux)
	#
	# Linux
	#
	CC="cc"
	CFLAGS="-std=c99 -pedantic -O3 -Wall"
	CFLAGS="$CFLAGS -D_POSIX_C_SOURCE=200112L -D_XOPEN_SOURCE_EXTENDED"
	CFLAGS="$CFLAGS -D_FILE_OFFSET_BITS=64 -I /usr/include/ncursesw"
	LIBS="-lncursesw"
	;;
Darwin)
	#
	# MacOS X (native curses is ncurses, LFS by default)
	#
	CC="cc"
	CFLAGS="-std=c99 -pedantic -O3 -Wall"
	CFLAGS="$CFLAGS -D_POSIX_C_SOURCE=200112L -D_XOPEN_SOURCE_EXTENDED"
	CFLAGS="$CFLAGS -DUSE_CURSES"
	LIBS="-lcurses"
	;;
FreeBSD)
	#
	# FreeBSD (LFS by default)
	#
	CC="cc"
	CFLAGS="-std=c99 -pedantic -O3 -Wall -D_XOPEN_SOURCE_EXTENDED"
	LIBS="-lncursesw"
	;;
OpenBSD)
	#
	# OpenBSD (native curses is ncurses, LFS by default)
	#
	CC="cc"
	CFLAGS="-std=c99 -pedantic -O3 -Wall -D_XOPEN_SOURCE_EXTENDED"
	LIBS="-lncursesw"
	;;
NetBSD)
	#
	# NetBSD (use native curses library, LFS by default)
	#
	CC="cc"
	CFLAGS="-std=c99 -pedantic -O3 -Wall -DUSE_CURSES"
	LIBS="-lcurses"
	;;
SunOS)
	#
	# Solaris 
	#
	# - Sun Blade 150 (i.e., UltraSPARC IIe, 64 bit)
	# - Solaris 9
	# - Forte 7 Developer compiler
	# - ncurses from www.opencsw.org
	#
	CC="/opt/SUNWspro/bin/cc"
	NCURSESROOT="/opt/csw"
	CFLAGS="-xc99=%all -fast -xarch=v9a -xchip=ultra2e -DOLD_SOLARIS"
	CFLAGS="$CFLAGS -D_XOPEN_SOURCE_EXTENDED -D__EXTENSIONS__"
	CFLAGS="$CFLAGS -D_FILE_OFFSET_BITS=64"
	CFLAGS="$CFLAGS -I $NCURSESROOT/include/ncursesw"
	CFLAGS="$CFLAGS -I $NCURSESROOT/include"
	LIBS="-L $NCURSESROOT/lib/64 -R $NCURSESROOT/lib/64 -lncursesw -lrt"
	#
	# - SparcClassic (i.e., microSPARC, 32 bit)
	# - Solaris 9
	# - Forte 7 Developer compiler
	# - ncurses from www.opencsw.org
	# - don't try this configuration unless you are a masochist :-)
	#
	#CC="/opt/SUNWspro/bin/cc"
	#NCURSESROOT="/opt/csw"
	#CFLAGS="-xc99=%all -fast -xtarget=sslc -DOLD_SOLARIS"
	#CFLAGS="$CFLAGS -D_XOPEN_SOURCE_EXTENDED -D__EXTENSIONS__"
	#CFLAGS="$CFLAGS -D_FILE_OFFSET_BITS=64"
	#CFLAGS="$CFLAGS -I $NCURSESROOT/include/ncursesw"
	#CFLAGS="$CFLAGS -I $NCURSESROOT/include"
	#LIBS="-L $NCURSESROOT/lib -R $NCURSESROOT/lib -lncursesw -lrt"
	#
	# - Pentium MMX (i.e., 32 bit)
	# - Solaris 9
	# - gcc 3.4.6 from www.opencsw.org
	# - ncurses from www.opencsw.org
	#
	#CC="/opt/csw/bin/gcc"
	#NCURSESROOT="/opt/csw"
	#CFLAGS="-std=gnu99 -pedantic -Wall -O3 -DOLD_SOLARIS"
	#CFLAGS="$CFLAGS -D_XOPEN_SOURCE_EXTENDED -D__EXTENSIONS__"
	#CFLAGS="$CFLAGS -D_FILE_OFFSET_BITS=64"
	#CFLAGS="$CFLAGS -I $NCURSESROOT/include/ncursesw"
	#CFLAGS="$CFLAGS -I $NCURSESROOT/include"
	#LIBS="-L $NCURSESROOT/lib -R $NCURSESROOT/lib -lncursesw -lrt"
	;;
AIX)
	#
	# AIX
	#
	# - RS/6000 7043 Model 150 (i.e., PowerPC 604e, 32 bit)
	# - AIX 5.3
	# - gcc 4.8.4 www.oss4aix.org
	# - ncurses from www.oss4aix.org
	#
	CC="gcc"
	NCURSESROOT="/opt/freeware"
	CFLAGS="-std=gnu99 -pedantic -Wall -O3"
	CFLAGS="$CFLAGS -D_LARGE_FILES -I$NCURSESROOT/include/ncursesw"
	LIBS="-L$NCURSESROOT/lib -lncursesw"
	;;
*)
	echo "unsupported OS platform \"$OS\", you need to adapt $0" 1>&2
	exit 1
	;;
esac

#
# execute make with the options and parameters collected above
#
make -f "makefile.mk" "$TARGET" CC="$CC" CFLAGS="$CFLAGS" LIBS="$LIBS"
