# $Id$
# Author: Daniel Bosk <daniel.bosk@miun.se>

MKFILES+=		depend.mk subdir.mk
MKFILES+=		package.mk export.mk pub.mk
MKFILES+=		doc.mk tex.mk noweb.mk
MKFILES+=		exam.mk results.mk

MIUNFILES+=		miun.docs.mk miun.tex.mk miun.subdir.mk
MIUNFILES+=		miun.package.mk miun.pub.mk miun.course.mk
MIUNFILES+=		miun.export.mk miun.results.mk latexmkrc
MIUNFILES+=		miun.depend.mk

OTHERS+=		gitattributes

.PHONY: all
all: makefiles.pdf
all: ${MKFILES}
all: ${MIUNFILES}
all: ${OTHERS}

makefiles.pdf: makefiles.tex intro.tex

define makefiles_depends
makefiles.pdf: $(1:.mk=.tex)
$(1) $(1:.mk=.tex): $(1).nw
endef

$(foreach mkfile,${MKFILES},$(eval $(call makefiles_depends,${mkfile})))

latexmkrc: tex.mk.nw
	notangle -t2 -R$@ $^ | cpif $@

gitattributes: export.mk.nw
	notangle -t2 -R$@ $^ | cpif $@


.PHONY: clean
clean:
	${RM} depend.tex
	${RM} subdir.tex
	${RM} package.tex
	${RM} export.tex
	${RM} pub.tex
	${RM} tex.tex
	${RM} doc.tex
	${RM} noweb.tex
	${RM} exam.tex
	${RM} results.tex


.PHONY: miun
miun: ${MIUNFILES}

PKG_PACKAGES?= 			main miun

PKG_PREFIX=				/usr/local
PKG_DIR=				/include

PKG_NAME-main= 			makefiles
PKG_FILES-main= 		${MKFILES}
PKG_TARBALL_FILES-main= ${PKG_FILES-main} ${OTHERS} Makefile README.md

PKG_NAME-miun=			build-all
PKG_FILES-miun= 		${MIUNFILES}
PKG_TARBALL_FILES-miun= ${PKG_FILES-miun} Makefile README.md

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
include ${INCLUDE_MAKEFILES}/tex.mk
include ${INCLUDE_MAKEFILES}/noweb.mk
include ${INCLUDE_MAKEFILES}/miun.port.mk
