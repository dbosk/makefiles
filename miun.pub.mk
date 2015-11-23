# $Id$
# Author: Daniel Bosk <daniel.bosk@miun.se>

ifndef MIUN_PUB_MK
MIUN_PUB_MK=true

SERVER?=	ver.miun.se
PUBDIR?=	/srv/web
CATEGORY?=
TMPDIR?=	/var/tmp

SSH_USER?=	${USER}
PUBGROUP?= 	svn

PUB_METHOD-main?= 	ssh
PUB_SERVER-main?= 	${SERVER}
PUB_DIR-main?= 		${PUBDIR}
PUB_CATEGORY-main?= ${CATEGORY}
PUB_FILES-main?= 	${PUB_FILES}
PUB_TMPDIR-main?= 	${TMPDIR}
PUB_GROUP-main?= 	svn

### INCLUDES ###

INCLUDE_MAKEFILES?= .
INCLUDES= 	depend.mk pub.mk

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
