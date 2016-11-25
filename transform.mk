ifndef EXPORT_MK
EXPORT_MK=true

EXPORT_SRC?=    .tex
EXPORT_DST?=    .transformed.tex
MATCH_PRINTANSWERS="/\\\\\\\\\\printanswers/s/^%//"
MATCH_HANDOUT="s/\\\\\\\\\\documentclass\\[?(.*)\\]?{beamer}/\\\\\\\\\\documentclass\\[\\1,handout\\]{beamer}/"
GPG?=                 gpg
EXPORT_ENC?=          ${GPG} -aes
EXPORT_RECIPIENTS?=   me
EXPORT_DEC?=          ${GPG} -d
define transform
cat $(1) $(foreach t,$(2),| $(call ${t})) > $(3)
endef
NoSolutions?= ${SED} "/\\\\begin{solution}/,/\\\\end{solution}/d"
ExportFilter?=${SED} "/#export \\(false\\|no\\)/,/#export \\(true\\|yes\\)/d"
OldExportFilter?=   ${SED} "/#export no/,/#endexport/d"
.SUFFIXES: .dvi .ps
.dvi.ps:
	${DVIPS} ${DVIPSFLAGS} $<

# $1 = input file
# $2 = output file
define sed_transformations
${CAT} $1 \
	$(shell [ "${solutions}" = "no" ] || echo \
	" | ${SEDex} \"${MATCH_PRINTANSWERS}\" " ) \
	$(shell [ "${handout}" = "no" ] || echo \
	" | ${SEDex} \"${MATCH_HANDOUT}\" " ) \
	> $2
endef

# $1 = original file
# $2 = new file
# $3 = backup file
define backup_file
if diff -u $1 $2; then \
	mv $1 $3 && mv $2 $1; \
fi
endef

# $1 = backup file
# $2 = original file
define restore_file
if [ -f $1 ]; then \
	${MV} $1 $2; \
fi
endef
.SUFFIXES: ${EXPORT_SRC} ${EXPORT_DST}
$(foreach src,${EXPORT_SRC},$(foreach dst,${EXPORT_DST},${src}${dst})):
	$(call transform,$^,${EXPORT_TRANSFORM-$@},$@)
define target_recipe
$(1):
	$(call transform,$^,${EXPORT_TRANSFORM-$@},$@)
endef
$(foreach target,${EXPORT_TARGETS},$(eval $(call target_recipe,${target})))
define bibliography
${SED} \
  -e "/\\\\bibliography{[^}]*}/{s/\\\\bibliography.*//;r $(1)" \
  -e "}"
endef
define filecontent
${SED} "/^%\\\\begin{filecontents\\*\\?}{$(1)}/,/^%\\\\end{filecontents\\*\\?}/s/^%//" \
  | ${SED} "/^\\\\begin{filecontents\\*\\?}{$(1)}/r $(1)"
endef
define _the_bblcode
\\\\makeatletter\\\\def\\\\blx@bblfile@biber{\\\\blx@secinit\\\\begingroup\\\\blx@bblstart\\\\input{\\\\jobname.bbl}\\\\blx@bblend\\\\endgroup\\\\csnumgdef{blx@labelnumber@\\\\the\\\\c@refsection}{0}}\\\\makeatother
endef

define bblcode
${SED} "s/^%biblatex-bbl-code/${_the_bblcode}/"
endef

.SUFFIXES: .tex .cameraready.tex
.tex.cameraready.tex:
  cat $< \
	  | $(call filecontent,\
	    $(shell ${SED} -n "s/^%\\\\begin{filecontents\\*\\?}{\\([^}]*\\)}/\\1/p" \
	    $<)) \
	  | $(call bibliography,${<:.tex=.bbl}) \
	  | $(call bblcode) \
	  > $@
.SUFFIXES: .tex .tex.asc
.tex.tex.asc:
	${EXPORT_ENC} $(foreach r,${EXPORT_RECIPIENTS}, -r $r) < $< > $@

.tex.asc.tex:
	${EXPORT_DEC} < $< > $@

include ${INCLUDE_MAKEFILES}/portability.mk

endif
