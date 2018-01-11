ifndef SUBDIR_MK
SUBDIR_MK=true

ifdef SUBDIR
${SUBDIR}::
	${MAKE} -C $@ ${MAKECMDGOALS}
endif

SUBDIR_ALL?=yes

ifeq (${SUBDIR_ALL},yes)
ifneq (${MAKECMDGOALS},)
.PHONY: ${MAKECMDGOALS}
${MAKECMDGOALS}: ${SUBDIR}
else
${.DEFAULT_GOAL}: ${SUBDIR}
endif
endif

endif
