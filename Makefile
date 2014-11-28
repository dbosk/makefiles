# $Id$
# Author: Daniel Bosk <daniel.bosk@miun.se>

MKFILES=		miun.docs.mk miun.tex.mk miun.subdir.mk
MKFILES+=		miun.package.mk miun.pub.mk miun.course.mk
MKFILES+=		miun.export.mk miun.results.mk latexmkrc
MKFILES+=		miun.depend.mk

PACKAGE?=		build-all
PACKAGE_FILES?=	${MKFILES} Makefile README.md
INSTALL_FILES?=	${MKFILES}
PREFIX?=		/usr/local
INSTALLDIR?=	/include

SERVER?=		ver.miun.se
PUBDIR?=		/srv/web/svn
CATEGORY?=		build
PUB_FILES?=		${PACKAGE_FILES} ${PACKAGE}.tar.gz

clean:
	${RM} depend.mk pub.mk package.mk miun.port.mk

depend.mk pub.mk package.mk miun.port.mk:
	wget https://raw.githubusercontent.com/dbosk/makefiles/master/$@

include depend.mk
include pub.mk
include package.mk
include miun.port.mk
