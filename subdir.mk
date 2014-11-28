# $Id$
# Author: Daniel Bosk <daniel.bosk@miun.se>

ifndef SUBDIR_MK
SUBDIR_MK=true

ifdef SUBDIR
ifneq (${MAKECMDGOALS},)
.PHONY: ${MAKECMDGOALS}
${MAKECMDGOALS}: ${SUBDIR}
endif

${SUBDIR}::
	${MAKE} -C $@ ${MAKECMDGOALS}
endif

endif
