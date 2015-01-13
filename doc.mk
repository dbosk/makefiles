# $Id$
# Author: Daniel Bosk <daniel.bosk@miun.se>

ifndef DOC_MK
DOC_MK=true

# add these to the document specific Makefile
DOCUMENTS?=	

PRINT?=		lpr

.PHONY: all
all: ${DOCUMENTS}

.PHONY: print
print: ${DOCUMENTS:.pdf=.ps}
	for d in $^ ; do \
		[ -d $${d} ] || ${PRINT} $${d}; \
	done

.PHONY: clean-doc
clean-doc: clean-tex
ifneq (${DOCUMENTS},)
	${RM} ${DOCUMENTS} ${DOCUMENTS:.pdf=.ps}
endif

.PHONY: clean
clean: clean-doc

.PHONY: todo
todo:
	-@grep -e 'TODO ' -e 'XXX ' *


### INCLUDES ###

INCLUDES= 	depend.mk pub.mk tex.mk

pub.mk: depend.mk
tex.mk: depend.mk

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
