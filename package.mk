# $Id$
# Author: Daniel Bosk <daniel.bosk@miun.se>

ifndef PACKAGE_MK
PACKAGE_MK=true

# specify all packages
PKG_PACKAGES?= 			main

IGNORE_FILES?=	\(\.svn\|\.git\|CVS\)

# these three variables should be set in $PACKAGE/Makefile for each package
define variables
PKG_NAME-$(1)?= 		${PACKAGE}
PKG_FILES-$(1)?= 		${PACKAGE_FILES} ${INSTALL_FILES}
PKG_PREFIX-$(1)?=		${PREFIX}
PKG_DIR-$(1)?= 			${INSTALLDIR}

# these will usually not need any changes
PKG_TARBALL-$(1)?=		${PKG_NAME-$(1)}.tar.gz
PKG_TARBALL_FILES-$(1)?=${PKG_FILES-$(1)} ${TARBALL_FILES}
PKG_IGNORE-$(1)?= 		${IGNORE_FILES}
endef

# set up default values for all packages, for which values are not already set
$(foreach pkg,${PKG_PACKAGES},$(eval $(call variables,${pkg})))


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

.PHONY: all
define all
all: ${PKG_TARBALL-$(1)} ${PKG_FILES-$(1)}
endef
$(foreach pkg,${PKG_PACKAGES},$(eval $(call all,${pkg})))

define tarball
${PKG_TARBALL-$(1)}: ${PKG_TARBALL_FILES-$(1)} pax
	[ -n "${PKG_TARBALL_FILES-$(1)}" ] && \
		find ${PKG_TARBALL_FILES-$(1)} -type f -or -type l | \
		xargs ${TAR} -f $$@ \
		-s "|^.*/${PKG_IGNORE-$(1)}/.*$$$$||p" \
		-s "|^\(.*\).export$$$$|${PKG_NAME-$(1)}/\1|p" \
		-s "|^\(.*\)\.export\([^.]*\)$$$$|${PKG_NAME-$(1)}/\1\.\2|p" \
		-s "|^|${PKG_NAME-$(1)}/|p"
endef
$(foreach pkg,${PKG_PACKAGES},$(eval $(call tarball,${pkg})))

.PHONY: package
package:

define package
package: ${PKG_TARBALL-$(1)}
endef
$(foreach pkg,${PKG_PACKAGES},$(eval $(call package,${pkg})))

.PHONY: clean-package
clean-package:

define clean-package
clean-package: clean-package-$(1)
clean-package-$(1):
	${RM} ${PKG_TARBALL-$(1)}
endef
$(foreach pkg,${PKG_PACKAGES},$(eval $(call clean-package,${pkg})))

.PHONY: clean
clean: clean-package

.PHONY: install
install: post-install

.PHONY: pre-install
pre-install:

define pre-install
pre-install: pre-install-$(1)
pre-install-$(1):
endef
$(foreach pkg,${PKG_PACKAGES},$(eval $(call pre-install,${pkg})))

.PHONY: do-install
do-install: pre-install

define do-install
do-install: do-install-$(1)
do-install-$(1): pre-install-$(1) ${PKG_FILES-$(1)}
	${MKDIR} ${PKG_PREFIX-$(1)}${PKG_DIR-$(1)}/
	for f in ${PKG_FILES-$(1)}; do \
		[ -d "$$$$f" ] || ${INSTALL} "$$$$f" ${PKG_PREFIX-$(1)}${PKG_DIR-$(1)}/; \
	done
endef
$(foreach pkg,${PKG_PACKAGES},$(eval $(call do-install,${pkg})))

.PHONY: post-install
post-install: do-install

define post-install
post-install: post-install-$(1)
post-install-$(1):
endef
$(foreach pkg,${PKG_PACKAGES},$(eval $(call post-install,${pkg})))

### INCLUDES ###

INCLUDE_MAKEFILES?= .
INCLUDES= 	depend.mk export.mk

define inc
ifeq ($(findstring $(1),${MAKEFILE_LIST}),)
$(1):
	wget https://raw.githubusercontent.com/dbosk/makefiles/master/$(1)
include ${INCLUDE_MAKEFILES}/$(1)
endif
endef
$(foreach i,${INCLUDES},$(eval $(call inc,$i)))

### END INCLUDES ###

endif
