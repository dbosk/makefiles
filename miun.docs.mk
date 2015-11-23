# $Id$
# Author: Daniel Bosk <daniel.bosk@miun.se>

ifndef MIUN_DOCS_MK
MIUN_DOCS_MK=true

# add these to the document specific Makefile
SOURCES?=	${FILES}
DOCUMENTS?=	
PUB_FILES?=	${DOCUMENTS}
SERVER?=	ver.miun.se
PUBDIR?=	/srv/web/documents
CATEGORY?=	
# the documents will be published to $SERVER/$PUBDIR/$CATEGORY

### INCLUDES ###

INCLUDE_MAKEFILES?= .
INCLUDES= 	doc.mk tex.mk miun.depend.mk miun.pub.mk

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
