# $Id$
# Author: Daniel Bosk <daniel.bosk@miun.se>

MKFILES+=		miun.docs.mk miun.tex.mk miun.subdir.mk
MKFILES+=		miun.package.mk miun.pub.mk miun.course.mk
MKFILES+=		miun.export.mk miun.results.mk latexmkrc
MKFILES+=		miun.depend.mk

.PHONY: all
all: ${MKFILES} makefiles.pdf

makefiles.pdf: makefiles.tex intro.tex

makefiles.pdf: exam.tex
all: exam.mk
exam.mk exam.tex: exam.mk.nw

makefiles.pdf: miun.results.tex
all: miun.results.mk
miun.results.mk miun.results.tex: miun.results.mk.nw


.PHONY: miun
miun: ${MKFILES}

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
PUB_METHOD-miun?= 		ssh
PUB_GROUP-miun?= 		svn
PUB_FILES-miun?=		${PKG_FILES-miun} ${PKG_NAME-miun}.tar.gz


INCLUDE_MAKEFILES=.
include ${INCLUDE_MAKEFILES}/depend.mk
include ${INCLUDE_MAKEFILES}/pub.mk
include ${INCLUDE_MAKEFILES}/package.mk
include ${INCLUDE_MAKEFILES}/miun.port.mk
include ${INCLUDE_MAKEFILES}/tex.mk
include ${INCLUDE_MAKEFILES}/noweb.mk
