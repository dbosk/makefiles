# $Id$
# Author: Daniel Bosk <daniel@bosk.se>

ifndef PUB_MK
PUB_MK=true

at?=

# possible values: git, svn, cvs
VCS?= 			git
AUTOCOMMIT?= 	false
COMMIT_OPTS?= 	
AUTOTAG?= 		false
TAG_OPTS?= 		

PUB_BRANCH?= 			master

# the sites used to publish
PUB_SITES?= 	main

# add these to the document specific Makefile
define variables
# possible values: ssh, at, git
PUB_METHOD-$(1)?= 		ssh

PUB_FILES-$(1)?=		${PUB_FILES}
# must be a regex
PUB_IGNORE_FILES-$(1)?=	\(\.svn\|\.git\|CVS\)
# if git is used the above variables are ignored
# instead we use the branch
PUB_BRANCH-$(1)?= 		${PUB_BRANCH}

PUB_SERVER-$(1)?=		localhost
PUB_DIR-$(1)?=			/pub
PUB_CATEGORY-$(1)?= 	${PUB_CATEGORY}
PUB_TMPDIR-$(1)?=		/var/tmp

PUB_USER-$(1)?=			${USER}
PUB_GROUP-$(1)?= 		${USER}
PUB_CHMOD-$(1)?= 		o+r
endef

# set up default values for all sites, for which values are not already set
$(foreach site,${PUB_SITES},$(eval $(call variables,${site})))

SSH?=		ssh
SCP?=		scp -r
SFTP?=		sftp
PAX=		pax -wL
UNPAX=		pax -r
CP?=		cp -R

.PHONY: publish
publish: pax
publish: $(foreach site,${PUB_SITES},${PUB_FILES-${site}})
ifneq (${AUTOCOMMIT},false)
	$(call autocommit-${VCS}))
endif
ifneq (${AUTOTAG},false)
	$(call autotag-${VCS}))
endif
	$(foreach site,${PUB_SITES},\
		$(call publish-${PUB_METHOD-${site}},\
		${PUB_SERVER-${site}},\
		${PUB_DIR-${site}}/${PUB_CATEGORY-${site}},\
		${PUB_USER-${site}},\
		${PUB_GROUP-${site}},\
		${PUB_CHMOD-${site}},\
		${PUB_FILES-${site}},\
		${PUB_IGNORE_FILES-${site}},\
		${PUB_TMPDIR-${site}},\
		${PUB_BRANCH-${site}}\
		))

define autocommit-svn
	! ( svn status | grep W155007 > /dev/null ) || svn commit ${COMMIT_OPTS}
endef

define autocommit-git
	! git status > /dev/null || ( \
		git commit -a ${COMMIT_OPTS} && git pull && git push || \
		git svn rebase && git svn dcommit || true \
	)
endef

define autocommit-cvs
	[ ! -d CVS ] || cvs commit ${COMMIT_OPTS}
endef

define autotag-svn
	if [ -d .svn -a -d ../trunk -a -d ../tags ]; then \
		cd .. && svn copy trunk tags/$$(date +%Y%m%d-%H%M); \
		echo "Do not forget to commit tags/, unless you change your mind"; \
		echo "about this release."; \
	fi
endef

define autotag-git
	git tag $$(date +%Y%m%d-%H%M)
endef

define autotag-cvs
	cvs tag $$(date +%Y%m%d-%H%M)
endef

# $(1) = ${SERVER}
# $(2) = ${PUB_DIR}/${PUB_CATEGORY}
# $(3) = ${PUB_USER}
# $(4) = ${PUB_GROUP}
define chown
	$(if $(4),-${SSH} $(1) chown -R $(3):$(strip $(4)) $(2),)
endef

# $(1) = ${SERVER}
# $(2) = ${PUB_DIR}/${PUB_CATEGORY}
# $(3) = ${PUB_CHMOD}
define chmod
	$(if $(3),-${SSH} $(1) chmod -R $(3) $(2),)
endef

# $(1) = ${SERVER}
# $(2) = ${PUB_DIR}/${PUB_CATEGORY}
# $(3) = ${PUB_USER}
# $(4) = ${PUB_GROUP}
# $(5) = ${PUB_CHMOD}
# $(6) = ${PUB_FILES}
# $(7) = ${PUB_IGNORE_FILES}
# $(8) = ${PUB_TMPDIR}
define publish-ssh
	${SSH} $(1) mkdir -p $(2)
	[ -n "$(6)" ] && find $(6) -type f -or -type l | \
		xargs ${PAX} \
			-s "|^.*/$(strip $(7))/.*$$||p" \
			-s "|^\(.*\).export$$|\1|p" \
			-s "|^\(.*\)\.export\([^.]*\)$$|\1\.\2|p" | \
		${SSH} $(1) ${UNPAX} \
			-s "\"|^|$(strip $(2))/|p\""
	$(call chown,$(1),$(2),$(3),$(4))
	$(call chmod,$(1),$(2),$(5))
endef

# $(1) = ${SERVER}
# $(2) = ${PUB_DIR}/${PUB_CATEGORY}
# $(3) = ${PUB_USER}
# $(4) = ${PUB_GROUP}
# $(5) = ${PUB_CHMOD}
# $(6) = ${PUB_FILES}
# $(7) = ${PUB_IGNORE_FILES}
# $(8) = ${PUB_TMPDIR}
define publish-at
	${SSH} $(1} mkdir -p $(2)
	TMPPUB=$$(${SSH} $(1) "export TMPDIR=$(8) && \
		mktemp -d"); \
	[ -n "$(6)" ] && find $(6) -type f -or -type l | \
		xargs ${PAX} \
			-s "|^.*/$(strip $(7))/.*$$||p" \
			-s "|^\(.*\).export$$|\1|p" \
			-s "|^\(.*\)\.export\([^.]*\)$$|\1\.\2|p" | \
		${SSH} $(1) ${UNPAX} \
			-s "\"|^|$${TMPPUB}/|p\""; \
	${SSH} $(1) "cd $${TMPPUB} && (\
		echo 'mv $(6) $(2);' \
		$(if $(5),\
			echo 'chmod -R $(5) $(2);',) \
		$(if $(4),\
			echo 'chown -R $(3):$(strip $(4)) $(2);',) \
		) | at ${at}"
endef

# $(1) = ${SERVER}
# $(2) = ${PUB_DIR}/${PUB_CATEGORY}
# $(3) = ${PUB_USER}
# $(4) = ${PUB_GROUP}
# $(5) = ${PUB_CHMOD}
# $(6) = ${PUB_FILES}
# $(7) = ${PUB_IGNORE_FILES}
# $(8) = ${PUB_TMPDIR}
# $(9) = ${PUB_BRANCH}
define publish-git
	git archive $(9) $(6) | ssh $(1) pax -r -s ",^,$(strip $(2)),";
endef


INCLUDE_MAKEFILES?= .
include ${INCLUDE_MAKEFILES}/depend.mk

endif
