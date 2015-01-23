# $Id$
# Author: Daniel Bosk <daniel.bosk@miun.se>

MKFILES=		miun.docs.mk miun.tex.mk miun.subdir.mk
MKFILES+=		miun.package.mk miun.pub.mk miun.course.mk
MKFILES+=		miun.export.mk miun.results.mk latexmkrc
MKFILES+=		miun.depend.mk

PKG_PACKAGES?= 			main miun

PKG_NAME-main= 			makefiles
PKG_FILES-main= 		depend.mk package.mk pub.mk subdir.mk
PKG_FILES-main+= 		export.mk doc.mk tex.mk latexmkrc
PKG_TARBALL_FILES-main= ${PKG_FILES-main} Makefile README.md
PKG_PREFIX-main= 		/usr/local
PKG_DIR-main= 			/include

PKG_NAME-miun=			build-all
PKG_FILES-miun= 		${MKFILES}
PKG_TARBALL_FILES-miun= ${PKG_FILES-miun} Makefile README.md
PKG_PREFIX-miun=		/usr/local
PKG_DIR-miun= 			/include

PUB_SITES?= 			miun

PUB_SERVER-miun?=		ver.miun.se
PUB_DIR-miun?=			/srv/web/svn
PUB_CATEGORY-miun?=		build
PUB_GROUP-miun?= 		svn
PUB_FILES-miun?=		${PACKAGE_FILES} ${PACKAGE}.tar.gz

include depend.mk
include pub.mk
include package.mk
include miun.port.mk
