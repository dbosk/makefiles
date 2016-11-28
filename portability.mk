ifndef PORTABILITY_MK
PORTABILITY_MK=true

PORTABILITY_CONF?=  ${HOME}/.mk.conf /etc/mk.conf
-include ${PORTABILITY_CONF}

ifeq (${MAKE},gmake)
SED?=     gsed
SEDex?=   gsed -E
else
SED?=     sed
SEDex?=   sed -E
endif
ifeq (${MAKE},gmake)
GREP=     ggrep
GREPex=   ggrep -E
else
GREP=     grep
GREPex=   grep -E
endif
ifeq ($(shell uname),Darwin)
UNZIP?=   unzip
else
UNZIP?=   unzip -DD
endif
UNCOMPRESS?=  uncompress
CAT?=     cat
MV?=      mv
CP?=      cp -R
LN?=      ln
WC?=      wc
WCw?=     wc -w
XDGOPEN?= xdg-open

endif
