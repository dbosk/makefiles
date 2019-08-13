ifndef SUBDIR_MK
SUBDIR_MK=true

SUBDIR_GOALS?=${MAKECMDGOALS}
actual_goals=$(sort $(filter ${SUBDIR_GOALS},${MAKECMDGOALS}))

ifdef SUBDIR
${SUBDIR}::
	${MAKE} -C $@ ${actual_goals}
endif

ifneq (${SUBDIR_GOALS},)
ifneq (${actual_goals},)
.PHONY: ${actual_goals}
${actual_goals}: ${SUBDIR}
endif
ifneq ($(filter ${.DEFAULT_GOAL},${SUBDIR_GOALS}),)
.PHONY: ${.DEFAULT_GOAL}
${.DEFAULT_GOAL}: ${SUBDIR}
endif
endif

endif
