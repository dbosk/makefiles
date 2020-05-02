ifndef PORTABILITY_MK
PORTABILITY_MK=true

PORTABILITY_CONF?=  ${HOME}/.mk.conf /etc/mk.conf
-include ${PORTABILITY_CONF}

MV?=      mv
CP?=      cp -R
LN?=      ln -sf
MKDIR?=   mkdir -p
MKTMPDIR?=mktemp -d
CHOWN?=   chown -R
CHMOD?=   chmod -R
CAT?=     cat
OPEN?=    xdg-open
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
UNCOMPRESS.gz?=       ${GUNZIP} $<
UNCOMPRESS.z?=        ${UNCOMPRESS.gz}
COMPRESS_SUFFIXES+=   .gz
GZIP?=                gzip
COMPRESS.gz?=         ${GZIP} $<

ARCHIVE.a?=   ar r $@ $%
TAR?=         tar -u
PAX?=         pax -wzLx ustar
ARCHIVE.tar?= ${TAR} -f $@ $%
ZIP?=         zip
ARCHIVE.zip?= ${ZIP} -u $@ $%
UNTAR?=       tar -xm
UNPAX?=       pax -rzp m
EXTRACT.tar?= ${UNTAR} -f $< $@
ifeq ($(shell uname),Darwin)
UNZIP?=       unzip
else
UNZIP?=       unzip -DD
endif
EXTRACT.zip?= ${UNZIP} $< $@
(%):
	${ARCHIVE$(suffix $@)}
define extract
$(1): $(2)
	$${EXTRACT$(suffix $(2))}
endef

endif
