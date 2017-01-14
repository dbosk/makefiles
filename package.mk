ifndef PACKAGE_MK
PACKAGE_MK=true

INCLUDE_MAKEFILES?=.
include ${INCLUDE_MAKEFILES}/portability.mk

PKG_NAME?=          ${PACKAGE}
PKG_INSTALL_FILES?= ${INSTALL_FILES}
PKG_TARBALL_FILES?= ${PACKAGE_FILES} ${PKG_INSTALL_FILES}
IGNORE_FILES?=      \(\.svn\|\.git\|CVS\)
PKG_IGNORE?=        ${IGNORE_FILES}
PKG_PREFIX?=        ${PREFIX}
PKG_INSTALL_DIR?=   ${INSTALLDIR}
PKG_PACKAGES?=            main
define variables
PKG_NAME-$(1)?= 		      ${PKG_NAME}
PKG_INSTALL_FILES-$(1)?= 	${PKG_INSTALL_FILES}
PKG_PREFIX-$(1)?=         ${PKG_PREFIX}
PKG_INSTALL_DIR-$(1)?=    ${PKG_INSTALL_DIR}

PKG_TARBALL-$(1)?=        ${PKG_NAME-$(1)}.tar.gz
PKG_TARBALL_FILES-$(1)?=  ${PKG_TARBALL_FILES}
PKG_IGNORE-$(1)?=         ${PKG_IGNORE}
endef
$(foreach pkg,${PKG_PACKAGES},$(eval $(call variables,${pkg})))
ifneq (${MAKE},gmake)
INSTALL?=     install -Dp
else
INSTALL?=     install -CSp
endif
PKG_REGEX?=     "|^(.*)$$$$|\1|p"
$(foreach pkg,${PKG_PACKAGES},$(eval PKG_REGEX-${pkg}?=${PKG_REGEX}))
.PHONY: package
package: $(foreach pkg,${PKG_PACKAGES},${PKG_TARBALL-${pkg}})
define tarball
${PKG_TARBALL-$(1)}: ${PKG_TARBALL_FILES-$(1)}
endef
$(foreach pkg,${PKG_PACKAGES},$(eval $(call tarball,${pkg})))
$(sort $(foreach pkg,${PKG_PACKAGES},${PKG_TARBALL-${pkg}})):
	[ -n "$^" ] && \
	  find $^ -type f -or -type l \
	  | xargs ${TAR} -f $@ \
	    $(foreach regex,${PKG_REGEX-$(1)},-s ${regex}) \
	    -s "|^.*/${PKG_IGNORE-$(1)}/.*$$$$||p" \
	    -s "|^|${PKG_NAME-$(1)}/|p"
.PHONY: clean clean-package
clean: clean-package
define clean-package
.PHONY: clean-package-$(1)
clean-package: clean-package-$(1)
clean-package-$(1):
	${RM} ${PKG_TARBALL-$(1)}
endef
$(foreach pkg,${PKG_PACKAGES},$(eval $(call clean-package,${pkg})))
.PHONY: install
install: post-install
.PHONY: pre-install do-install post-install
post-install: do-install
do-install:   pre-install
pre-install:  ${PKG_INSTALL_FILES}
define post-install
.PHONY: post-install-$(1)
post-install: post-install-$(1)
post-install-$(1): do-install-$(1)
endef
$(foreach pkg,${PKG_PACKAGES},$(eval $(call post-install,${pkg})))

define do-install
.PHONY: do-install-$(1)
do-install: do-install-$(1)
do-install-$(1): pre-install-$(1)
	${MKDIR} ${PKG_PREFIX-$(1)}${PKG_INSTALL_DIR-$(1)}/
	for f in ${PKG_INSTALL_FILES-$(1)}; do \
	  [ -d "$$$$f" ] || ${INSTALL} "$$$$f" ${PKG_PREFIX-$(1)}${PKG_INSTALL_DIR-$(1)}/; \
	done
endef
$(foreach pkg,${PKG_PACKAGES},$(eval $(call do-install,${pkg})))

define pre-install
.PHONY: pre-install-$(1)
pre-install: pre-install-$(1)
pre-install-$(1): ${PKG_INSTALL_FILES-$(1)}
endef
$(foreach pkg,${PKG_PACKAGES},$(eval $(call pre-install,${pkg})))

endif
