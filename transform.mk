ifndef TRANSFORM_MK
TRANSFORM_MK=true

INCLUDE_MAKEFILES?=.
include ${INCLUDE_MAKEFILES}/portability.mk

TRANSFORM_SRC?=    .tex
TRANSFORM_DST?=    .transformed.tex
$(foreach suf,${TRANSFORM_DST},$(eval TRANSFORM_LIST${suf}?=${TRANSFORM_LIST}))
exam_class=       "(\\\\\\\\\\documentclass\\[?.*\\]?{.*exam.*})"
with_print=       "\\1\\\\\\\\\\printanswers"
SED_PRINTANSWERS= "s/${exam_class}/${with_print}/"
without_handout=  "\\\\\\\\\\documentclass\\[?(.*)\\]?{beamer}"
with_handout=     "\\\\\\\\\\documentclass\\[\\1,handout\\]{beamer}"
SED_HANDOUT=      "s/${without_handout}/${with_handout}/"
GPG?=                 gpg
TRANSFORM_ENC?=          ${GPG} -aes
TRANSFORM_RECIPIENTS?=   me
TRANSFORM_DEC?=          ${GPG} -d
define transform
cat $(1) $(foreach t,$(2),| $(call ${t})) > $(3)
endef
NoSolutions?= ${SED} "/\\\\begin{solution}/,/\\\\end{solution}/d"
ExportFilter?=    ${SED} "/#export \\(false\\|no\\)/,/#export \\(true\\|yes\\)/d"
OldExportFilter?= ${SED} "/#export no/,/#endexport/d"
PrintAnswers?=    ${SED} "${MATCH_PRINTANSWERS}"
Handout?=         ${SED} "${MATCH_HANDOUT}"
.SUFFIXES: ${TRANSFORM_SRC} ${TRANSFORM_DST}
$(foreach src,${TRANSFORM_SRC},$(foreach dst,${TRANSFORM_DST},${src}${dst})):
	$(call transform,\
	  $$^,\
	  $${TRANSFORM_LIST$$(suffix $$@)} $${TRANSFORM_LIST-$$@},\
	  $$@)
define target_recipe
$(1):
	$(call transform,\
	  $$^,\
	  $${TRANSFORM_LIST$$(suffix $$@)} $${TRANSFORM_LIST-$$@},\
	  $$@)
endef
$(foreach target,${TRANSFORM_TARGETS},$(eval $(call target_recipe,${target})))
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
	${TRANSFORM_ENC} $(foreach r,${TRANSFORM_RECIPIENTS}, -r $r) < $< > $@

.tex.asc.tex:
	${TRANSFORM_DEC} < $< > $@

endif
