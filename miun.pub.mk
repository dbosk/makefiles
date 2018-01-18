ifndef MIUN_PUB_MK
MIUN_PUB_MK=true

SERVER?=		ver.miun.se
PUBDIR?=		/srv/web/svn
CATEGORY?=
TMPDIR?=		/var/tmp
PUB_GROUP?= svn

ifdef NO_COMMIT
PUB_AUTOCOMMIT?=${NO_COMMIT}
endif

ifdef COMMIT_OPTS
PUB_COMMIT_OPTS?=${COMMIT_OPTS}
endif

INCLUDE_MAKEFILES?=.
include ${INCLUDE_MAKEFILES}/pub.mk

endif # MIUN_PUB_MK
