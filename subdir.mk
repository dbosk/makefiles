ifndef SUBDIR_MK
SUBDIR_MK=true

SUBDIR_GOALS?=${MAKECMDGOALS}
actual_goals=$(sort $(filter ${SUBDIR_GOALS},${MAKECMDGOALS} ${.DEFAULT_GOAL))

ifdef SUBDIR
${SUBDIR}::
	${MAKE} -C $@ ${actual_goals}
endif

ifneq (${SUBDIR_GOALS},)
ifneq (${actual_goals},)
.PHONY: ${actual_goals}
${actual_goals}: ${SUBDIR}
endif
endif

endif
