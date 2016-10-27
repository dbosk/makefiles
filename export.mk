ifndef EXPORT_MK
EXPORT_MK=true

ifeq (${MAKE},gmake)
SED?=     gsed
else
SED?=     sed
endif
GPG?=                 gpg
EXPORT_ENC?=          ${GPG} -aes
EXPORT_RECIPIENTS?=   me
EXPORT_DEC?=          ${GPG} -d
.SUFFIXES: .tex .export.tex
.tex.export.tex:
	${SED} "/\\\\begin{solution}/,/\\\\end{solution}/d" $< > $@
.SUFFIXES: .tex .tex.asc
.tex.tex.asc:
	${EXPORT_ENC} $(foreach r,${EXPORT_RECIPIENTS}, -r $r) < $< > $@

.tex.asc.tex:
	${EXPORT_DEC} < $< > $@
Makefile.export:
	${SED} "/#export false/,/#export true/d" $< > $@

endif
