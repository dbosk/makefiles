# $Id$
# Author: Daniel Bosk <daniel.bosk@miun.se>

ifndef PACKAGE_MK
PACKAGE_MK=true

# these three variables should be set in $PACKAGE/Makefile
PACKAGE?=		
PACKAGE_FILES?=	
INSTALL_FILES?=	${PACKAGE_FILES}
DOCS_FILES?=
PREFIX?=		
INSTALLDIR?=	${PACKAGE}
DOCSDIR?=		${PACKAGE}

# these will usually not need any changes
TARBALL?=		${PACKAGE}
TARBALL_FILES?=	${PACKAGE_FILES}
TARBALL_NAME=	${TARBALL}.tar.gz

IGNORE_FILES?=	\(\.svn\|\.git\|CVS\)

MKDIR?=		mkdir -p
CP?=		cp -R
RM?=		rm -Rf
TAR=		pax -wzLx ustar
UNTAR=		pax -rz
ifneq (${MAKE},gmake)
INSTALL?=	install -Dp
else
INSTALL?=	install -CSp
endif

.PHONY: all package clean-package install clean

all: ${TARBALL_NAME} ${PACKAGE_FILES} ${INSTALL_FILES} ${DOCS_FILES}

${TARBALL_NAME}: ${TARBALL_FILES} pax
	[ -n "${TARBALL_FILES}" ] && find ${TARBALL_FILES} -type f -or -type l | \
		xargs ${TAR} -f ${TARBALL_NAME} \
		-s "|^.*/${IGNORE_FILES}/.*$$||p" \
		-s "|^\(.*\).export$$|${TARBALL}/\1|p" \
		-s "|^\(.*\)\.export\([^.]*\)$$|${TARBALL}/\1\.\2|p" \
		-s "|^|${TARBALL}/|p"

package: ${TARBALL_NAME}

clean-package:
ifneq (${TARBALL_NAME},)
	${RM} ${TARBALL_NAME}
endif

clean: clean-package

install: pre-install do-install post-install

pre-install:

do-install: ${INSTALL_FILES} ${DOCS_FILES}
ifneq (${INSTALL_FILES},)
	${MKDIR} ${PREFIX}${INSTALLDIR}/
	for f in ${INSTALL_FILES}; do \
		[ -d "$$f" ] || ${INSTALL} "$$f" ${PREFIX}${INSTALLDIR}/; \
	done
endif
ifneq (${DOCS_FILES},)
	${MKDIR} ${PREFIX}${DOCSDIR}/
	for f in ${DOCS_FILES}; do \
		[ -d "$$f" ] || ${INSTALL} "$$f" ${PREFIX}${DOCSDIR}/; \
	done
endif

post-install:

### INCLUDES ###

INCLUDES= 	depend.mk export.mk

export.mk: depend.mk

define inc
ifeq ($(findstring $(1),${MAKEFILE_LIST}),)
$(1):
	wget https://raw.githubusercontent.com/dbosk/makefiles/master/$(1)
include $(1)
endif
endef
$(foreach i,${INCLUDES},$(eval $(call inc,$i)))

### END INCLUDES ###

endif
