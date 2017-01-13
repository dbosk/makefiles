ifndef PORTABILITY_MK
PORTABILITY_MK=true

PORTABILITY_CONF?=  ${HOME}/.mk.conf /etc/mk.conf
-include ${PORTABILITY_CONF}

MV?=      mv
CP?=      cp -R
LN?=      ln
MKDIR?=   mkdir -p
MKTMPDIR?=mktemp -d
CHOWN?=   chown -R
CHMOD?=   chmod -R
CAT?=     cat
XDGOPEN?= xdg-open
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
WC?=      wc
WCw?=     wc -w
CURL?=    curl
SFTP?=    sftp
SCP?=     scp -r
SSH?=     ssh
UNCOMPRESS_SUFFIXES+= .gz .z
GUNZIP?=              gunzip
UNCOMPRESS.gz?=       ${GUNZIP} $$<
UNCOMPRESS.z?=        ${UNCOMPRESS.gz}
COMPRESS_SUFFIXES+=   .gz
GZIP?=                gzip
COMPRESS.gz?=         ${GZIP} $$<
define uncompress
%: %$(1)
	${UNCOMPRESS$(1)}
endef
$(foreach suf,${UNCOMPRESS_SUFFIXES},$(eval $(call uncompress,${suf})))

ARCHIVE.a?=   ar r $@ $%
TAR?=         pax -wzLx ustar
ARCHIVE.tar?= ${TAR} -uf $@ $%
ZIP?=         zip
ARCHIVE.zip?= ${ZIP} -u $@ $%
UNTAR?=       pax -rzp m
EXTRACT.tar?= ${UNTAR} -f $$< $$@
ifeq ($(shell uname),Darwin)
UNZIP?=       unzip
else
UNZIP?=       unzip -DD
endif
EXTRACT.zip?= ${UNZIP} $$< $$@
(%):
	${ARCHIVE$(suffix $@)}
define extract
$(1): $(2)
	${EXTRACT$(suffix $(2))}
endef

endif
