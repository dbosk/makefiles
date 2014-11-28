# $Id$
# Author: Daniel Bosk <daniel.bosk@miun.se>

ifndef MIUN_DOCS_MK
MIUN_DOCS_MK=true

# add these to the document specific Makefile
SOURCES?=	${FILES}
DOCUMENTS?=	
PUB_FILES?=	${DOCUMENTS}
SERVER?=	ver.miun.se
PUBDIR?=	/srv/web/svn/dokument
CATEGORY?=	
# the documents will be published to $SERVER/$PUBDIR/$CATEGORY

### INCLUDES ###

INCLUDES= 	doc.mk miun.depend.mk miun.pub.mk miun.tex.mk

define inc
ifeq ($(findstring $(1),${MAKEFILE_LIST}),)
$(1):
	wget https://raw.githubusercontent.com/dbosk/makefiles/master/$@
include $(1)
endif
endef
$(foreach i,${INCLUDES},$(call inc,$i))

### END INCLUDES ###

endif
