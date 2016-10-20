ifndef SUBDIR_MK
SUBDIR_MK=true

ifdef SUBDIR
ifneq (${MAKECMDGOALS},)
.PHONY: ${MAKECMDGOALS}
${MAKECMDGOALS}: ${SUBDIR}
else
${.DEFAULT_GOAL}: ${SUBDIR}
endif
${SUBDIR}::
	${MAKE} -C $@ ${MAKECMDGOALS}
endif

endif
