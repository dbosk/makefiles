# $Id$
# Author: Daniel Bosk <daniel.bosk@miun.se>

ifndef MIUN_PUB_MK
MIUN_PUB_MK=true

SERVER?=	ver.miun.se
PUBDIR?=	/srv/web/svn
CATEGORY?=
TMPDIR?=	/var/tmp

SSH_USER?=	${USER}
PUBGROUP?= 	svn

### INCLUDES ###

INCLUDES= 	depend.mk pub.mk

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
