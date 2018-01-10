ifndef MIUN_DOCS_MK
MIUN_DOCS_MK=true

DOCUMENTS?=
PUB_FILES?=   ${DOCUMENTS}
SERVER?=      ver.miun.se
PUBDIR?=      /srv/web/svn/dokument
CATEGORY?=	

ifdef PRINT
LPR?=         ${PRINT}
endif

.PHONY: all
all: ${DOCUMENTS}

.PHONY: print
print: ${DOCUMENTS:.pdf=.ps}

.PHONY: clean-docs
clean-docs:
ifneq (${DOCUMENTS},)
	${RM} ${DOCUMENTS}
endif

.PHONY: clean
clean: clean-docs

.PHONY: todo
todo: $(wildcard *)

INCLUDE_MAKEFILES?=.
include ${INCLUDE_MAKEFILES}/miun.tex.mk
include ${INCLUDE_MAKEFILES}/miun.pub.mk

endif # MIUN_DOCS_MK
