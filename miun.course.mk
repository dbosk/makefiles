ifndef MIUN_COURSE_MK
MIUN_COURSE_MK=true

DOCUMENTS?=
PUB_FILES?=   ${DOCUMENTS}
SERVER?=      ver.miun.se
PUBDIR?=      /srv/web/svn/courses
CATEGORY?=	

.PHONY: all
all: ${DOCUMENTS}

.PHONY: clean-course
clean-course:
ifneq (${DOCUMENTS},)
	${RM} ${DOCUMENTS}
endif

.PHONY: clean
clean: clean-course

INCLUDE_MAKEFILES?=.
include ${INCLUDE_MAKEFILES}/miun.docs.mk
include ${INCLUDE_MAKEFILES}/miun.export.mk

endif # MIUN_COURSE_MK
