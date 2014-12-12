# $Id$
# Author: Daniel Bosk <daniel.bosk@miun.se>

ifndef PUB_MK
PUB_MK=true

at?=
NO_COMMIT?= false

# add these to the document specific Makefile
PUB_FILES?=		

IGNORE_FILES?=	\(\.svn\|\.git\|CVS\)

# the $PUB_FILES will be published to $SERVER/$PUBDIR/$CATEGORY
SERVER?=	localhost
PUBDIR?=	/pub
CATEGORY?=
TMPDIR?=	/var/tmp

SSH?=		ssh
SCP?=		scp -r
SFTP?=		sftp
PAX=		pax -wL
UNPAX=		pax -r
CP?=		cp -R

COMMIT_OPTS?=

SSH_USER?=	${USER}
PUBGROUP?= 	svn

.PHONY: publish

publish: ${PUB_FILES} pax
ifneq (${NO_COMMIT},false)
	! ( svn status | grep W155007 > /dev/null ) || svn commit ${COMMIT_OPTS}
	! git status > /dev/null || ( \
		git commit -a ${COMMIT_OPTS} && git pull && git push || \
		git svn rebase && git svn dcommit || true \
	)
	[ ! -d CVS ] || cvs commit ${COMMIT_OPTS}
endif
	${SSH} -l ${SSH_USER} ${SERVER} mkdir -p ${PUBDIR}/${CATEGORY}
ifeq (${at},)
	[ -n "${PUB_FILES}" ] && find ${PUB_FILES} -type f -or -type l | \
		xargs ${PAX} \
			-s "|^.*/${IGNORE_FILES}/.*$$||p" \
			-s "|^\(.*\).export$$|\1|p" \
			-s "|^\(.*\)\.export\([^.]*\)$$|\1\.\2|p" | \
		${SSH} -l ${SSH_USER} ${SERVER} ${UNPAX} \
			-s "\"|^|${PUBDIR}/${CATEGORY}/|p\""
	-${SSH} -l ${SSH_USER} ${SERVER} chmod -R o+r ${PUBDIR}/${CATEGORY}
	-${SSH} -l ${SSH_USER} ${SERVER} chown -R :${PUBGROUP} ${PUBDIR}/${CATEGORY}
else
	TMPPUB=$$(${SSH} -l ${SSH_USER} ${SERVER} "export TMPDIR=${TMPDIR} && \
		mktemp -d"); \
	[ -n "${PUB_FILES}" ] && find ${PUB_FILES} -type f -or -type l | \
		xargs ${PAX} \
			-s "|^.*/${IGNORE_FILES}/.*$$||p" \
			-s "|^\(.*\).export$$|\1|p" \
			-s "|^\(.*\)\.export\([^.]*\)$$|\1\.\2|p" | \
		${SSH} -l ${SSH_USER} ${SERVER} ${UNPAX} \
			-s "\"|^|$${TMPPUB}/|p\""; \
	${SSH} -l ${SSH_USER} ${SERVER} "cd $${TMPPUB} && \
		echo 'mv ${PUB_FILES} ${PUBDIR}/${CATEGORY};' \
		echo 'chmod -R o+r ${PUBDIR}/${CATEGORY};' \
		$(if ${PUBGROUP},\
			echo 'chown -R :${PUBGROUP} ${PUBDIR}/${CATEGORY};',) | \
		at ${at}"
endif
	@if [ -d .svn -a -d ../trunk -a -d ../tags ]; then \
		cd .. && svn copy trunk tags/$$(date +%Y%m%d-%H%M); \
		echo "Do not forget to commit tags/, unless you change your mind"; \
		echo "about this release."; \
	fi

### INCLUDES ###

INCLUDES= 	depend.mk

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
