# $Id$
# Author: Daniel Bosk <daniel.bosk@miun.se>

ifndef MIUN_COURSE_MK
MIUN_COURSE_MK=true

# add these to the document specific Makefile
SOURCES?=	${FILES}
DOCUMENTS?=	
PUB_FILES?=	${DOCUMENTS}
SERVER?=	ver.miun.se
PUBDIR?=	/srv/web/svn/courses
CATEGORY?=	
# the documents will be published to $SERVER/$PUBDIR/$CATEGORY

.PHONY: all print clean clean-course todo

all: ${DOCUMENTS}

clean-course: clean-tex
ifneq (${DOCUMENTS},)
	${RM} ${DOCUMENTS}
endif

clean: clean-course


### INCLUDES ###

INCLUDES= 	miun.depend.mk miun.docs.mk miun.export.mk

define inc
ifeq ($(findstring $(1),${MAKEFILE_LIST}),)
$(1):
	wget https://raw.githubusercontent.com/dbosk/makefiles/master/$@
include $(1)
endif
endef
$(foreach i,${INCLUDES},$(eval $(call inc,$i)))

### END INCLUDES ###

endif
