ifndef SUBDIR_MK
SUBDIR_MK=true

ifdef SUBDIR
${SUBDIR}::
	${MAKE} -C $@ ${MAKECMDGOALS}
endif

SUBDIR_ALL_GOALS?=yes

ifeq (${SUBDIR_ALL_GOALS},yes)
ifneq (${MAKECMDGOALS},)
.PHONY: ${MAKECMDGOALS}
${MAKECMDGOALS}: ${SUBDIR}
else
${.DEFAULT_GOAL}: ${SUBDIR}
endif
endif

endif
