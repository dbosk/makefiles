ifndef TEX_MK
TEX_MK=true

.NOTPARALLEL:

INCLUDE_MAKEFILES?=.
include ${INCLUDE_MAKEFILES}/portability.mk

LATEX?=           latexmk -dvi -use-make -8bit
PDFLATEX?=        latexmk -pdf -use-make -8bit
LATEXFLAGS?=
PREPROCESS.tex?=  ${PDFLATEX} ${LATEXFLAGS} -output-directory=${TEX_OUTDIR} $<
PREPROCESS.dtx?=  ${PREPROCESS.tex}
TEX_OUTDIR?=      ltxobj
# The rerun loop is bounded: latexmk already reruns internally and gives
# up when the document does not converge, leaving "Rerun to get cross"
# in the log.  An unbounded loop would then relaunch latexmk forever.
# CHECK_LATEXMK decides what each run's exit status means: silence,
# a warning, or failure.  See tex.mk.nw for why a status of its own is
# not enough to tell a broken document from an unsettled one.
COMPILE.tex?=     \
  ${RUN_PDFLATEX}; ${CHECK_LATEXMK}; \
  for i in 1 2 3 4 5; do \
    grep "Rerun to get cross" ${TEX_OUTDIR}/${<:.tex=.log} || break; \
    ${RUN_PDFLATEX}; ${CHECK_LATEXMK}; \
  done; \
  exit 0
COMPILE.dtx?=     ${COMPILE.tex}
TEX_LATEXMKDIR?=    $(or ${TEX_OUTDIR},.)
TEX_LATEXMKLOG?=    ${TEX_LATEXMKDIR}/$(basename $(notdir $<)).latexmklog
TEX_LATEXMKSTATUS?= ${TEX_LATEXMKDIR}/$(basename $(notdir $<)).latexmkstatus
RUN_PDFLATEX?=      ${MKDIR} ${TEX_LATEXMKDIR}; \
  { ${PDFLATEX} ${LATEXFLAGS} -output-directory=${TEX_OUTDIR} $<; \
    echo $$? > ${TEX_LATEXMKSTATUS}; } 2>&1 | tee ${TEX_LATEXMKLOG}
RUN_LATEX?=         ${MKDIR} ${TEX_LATEXMKDIR}; \
  { ${LATEX} -output-directory=${TEX_OUTDIR} ${LATEXFLAGS} $<; \
    echo $$? > ${TEX_LATEXMKSTATUS}; } 2>&1 | tee ${TEX_LATEXMKLOG}
CHECK_LATEXMK?= \
  rc=$$(cat ${TEX_LATEXMKSTATUS} 2>/dev/null); [ -n "$$rc" ] || rc=1; \
  if [ "$$rc" = 0 ]; then :; \
  elif grep -q 'without getting stable files' ${TEX_LATEXMKLOG} && \
       ! grep -q 'Collected error summary' ${TEX_LATEXMKLOG} && \
       ! grep -qE '^make(\[[0-9]+\])?: \*\*\* \[.*\] Error ' \
           ${TEX_LATEXMKLOG}; \
  then \
    echo "tex.mk: WARNING: document did not stabilize (latexmk exit $$rc);" \
      "continuing -- the output is complete, but a page break oscillates" >&2; \
  else \
    exit $$rc; \
  fi
TEX_BBL?=
BIBTEX?=            bibtexu
BIBTEXFLAGS?=
BIBLIOGRAPHY.aux?=  ${BIBTEX} ${BIBTEXFLAGS} $<
BIBER?=             biber
BIBERFLAGS?=
BIBLIOGRAPHY.bcf?=  ${BIBER} -O $@ ${BIBERFLAGS} $<
TEX_IND?=
XINDY?=       texindy
XINDYFLAGS?=
COMPILE.idx?= ${XINDY} ${OUTPUT_OPTION} ${XINDYFLAGS} $<

MAKEINDEX?=   makeindex
MAKEIDXFLAGS?=
COMPILE.nlo?= ${MAKEINDEX} ${OUTPUT_OPTION} ${MAKEIDXFLAGS} -s nomencl.ist $<
TEX_PYTHONTEX?=
PYTHONTEX?=       python3 $$(which pythontex)
PYTHONTEXFLAGS?=  --interpreter python:python3
BIBTOOL?=     bibtool
BIBTOOLFLAGS?=--preserve.key.case=on --print.deleted.entries=off -s -d -r biblatex
ARCHIVE.bib?= ${CAT} $(if $(wildcard $@),$@) $% | \
  ${BIBTOOL} ${BIBTOOLFLAGS} -o $@
${TEX_OUTDIR}/%.aux: %.tex
	${MKDIR} ${TEX_OUTDIR}
	${PREPROCESS.tex}
${TEX_OUTDIR}/%.bbl: ${TEX_OUTDIR}/%.aux
	${BIBLIOGRAPHY.aux}
${TEX_OUTDIR}/%.bcf: %.tex
	${MKDIR} ${TEX_OUTDIR}
	${PREPROCESS.tex}
${TEX_OUTDIR}/%.bbl: ${TEX_OUTDIR}/%.bcf
	${BIBLIOGRAPHY.bcf}
ifneq (${TEX_BBL},)
%.pdf ${TEX_OUTDIR}/%.pdf: ${TEX_OUTDIR}/%.bbl
endif
ifneq (${TEX_PYTHONTEX},)
${TEX_OUTDIR}/%.pdf: ${TEX_OUTDIR}/%.pytxmcr
endif
${TEX_OUTDIR}/%.idx: %.tex
	${MKDIR} ${TEX_OUTDIR}
	${PREPROCESS.tex}
${TEX_OUTDIR}/%.ind: ${TEX_OUTDIR}/%.idx
	${COMPILE.idx}
ifneq (${TEX_IND},)
%.pdf ${TEX_OUTDIR}/%.pdf: ${TEX_OUTDIR}/%.ind
endif
${TEX_OUTDIR}/%.nlo: %.tex
	${MKDIR} ${TEX_OUTDIR}
	${PREPROCESS.tex}

${TEX_OUTDIR}/%.nls: ${TEX_OUTDIR}/%.nlo
	${COMPILE.nlo}
${TEX_OUTDIR}/%.pytxcode: ${TEX_OUTDIR}/%.aux
	cd $(dir $@) && ${PYTHONTEX} ${PYTHONTEXFLAGS} $(basename $(notdir $@))
%.pytxmcr:: ${TEX_OUTDIR}/%.pytxcode
	cd ${TEX_OUTDIR} && ${PYTHONTEX} ${PYTHONTEXFLAGS} $(basename $(notdir $@))
${TEX_OUTDIR}/%.pytxmcr:: ${TEX_OUTDIR}/%.pytxcode
	cd ${TEX_OUTDIR} && ${PYTHONTEX} ${PYTHONTEXFLAGS} $(basename $(notdir $@))
%.pdf: %.tex
	${COMPILE.tex}
	-[ "$(or ${TEX_OUTDIR},.)" -ef . ] || ${LN} ${TEX_OUTDIR}/$@ $@
${TEX_OUTDIR}/%.pdf: %.tex
	${COMPILE.tex}

%.dvi: %.tex
	${RUN_LATEX}; ${CHECK_LATEXMK}; \
	for i in 1 2 3 4 5; do \
	  grep "Rerun to get cross" ${TEX_OUTDIR}/${<:.tex=.log} || break; \
	  ${RUN_LATEX}; ${CHECK_LATEXMK}; \
	done; \
	exit 0
	-[ "$(or ${TEX_OUTDIR},.)" -ef . ] || ${LN} ${TEX_OUTDIR}/$@ $@
${TEX_OUTDIR}/%.dvi: %.tex
	${RUN_LATEX}; ${CHECK_LATEXMK}; \
	for i in 1 2 3 4 5; do \
	  grep "Rerun to get cross" ${TEX_OUTDIR}/${<:.tex=.log} || break; \
	  ${RUN_LATEX}; ${CHECK_LATEXMK}; \
	done; \
	exit 0
latexmkrc:
	[ -e $@ -o "${INCLUDE_MAKEFILES}" = "." ] || \
	${LN} -s ${INCLUDE_MAKEFILES}/latexmkrc $@
%.cls %.sty: %.ins
	${LATEX} $<
%.pdf: %.dtx
	${COMPILE.dtx}
	-[ "$(or ${TEX_OUTDIR},.)" -ef . ] || ${LN} ${TEX_OUTDIR}/$@ $@
${TEX_OUTDIR}/%.pdf: %.dtx
	${COMPILE.dtx}

%.dvi: %.dtx
	${RUN_LATEX}; ${CHECK_LATEXMK}; \
	for i in 1 2 3 4 5; do \
	  grep "Rerun to get cross" ${TEX_OUTDIR}/${<:.tex=.log} || break; \
	  ${RUN_LATEX}; ${CHECK_LATEXMK}; \
	done; \
	exit 0
	-[ "$(or ${TEX_OUTDIR},.)" -ef . ] || ${LN} ${TEX_OUTDIR}/$@ $@
${TEX_OUTDIR}/%.dvi: %.dtx
	${RUN_LATEX}; ${CHECK_LATEXMK}; \
	for i in 1 2 3 4 5; do \
	  grep "Rerun to get cross" ${TEX_OUTDIR}/${<:.tex=.log} || break; \
	  ${RUN_LATEX}; ${CHECK_LATEXMK}; \
	done; \
	exit 0
${TEX_OUTDIR}/%.aux: %.dtx
	${MKDIR} ${TEX_OUTDIR}
	${PREPROCESS.dtx}
${TEX_OUTDIR}/%.bcf: %.dtx
	${MKDIR} ${TEX_OUTDIR}
	${PREPROCESS.dtx}
${TEX_OUTDIR}/%.idx: %.dtx
	${MKDIR} ${TEX_OUTDIR}
	${PREPROCESS.dtx}
define download_archive
$(foreach file,${TEX_EXT_FILES-$(1)},\
  $(eval $(notdir ${file}): ${TEX_EXT_DIR-$(1)}/${file}))
$(notdir ${TEX_EXT_FILES-$(1)}):
	${LN} $$^ $$@
.PHONY: $(1)
$(1): $(notdir ${TEX_EXT_FILES-$(1)})
$(addprefix ${TEX_EXT_DIR-$(1)}/,${TEX_EXT_FILES-$(1)}): \
  ${TEX_EXT_DIR-$(1)}/${TEX_EXT_SRC-$(1)}
$(addprefix ${TEX_EXT_DIR-$(1)}/,${TEX_EXT_FILES-$(1)}):
	${TEX_EXT_EXTRACT-$(1)}
${TEX_EXT_DIR-$(1)}/${TEX_EXT_SRC-$(1)}:
	${MKDIR} ${TEX_EXT_DIR-$(1)}
	${CURL} -o $$@ ${TEX_EXT_URL-$(1)}
.PHONY: distclean clean-$(1)
distclean: clean-$(1)
clean-$(1):
	${RM} ${TEX_EXT_FILES-$(1)}
	[ "${TEX_EXT_DIR-$(1)}" = "." ] && ${RM} ${TEX_EXT_SRC-$(1)} \
	  || ${RM} -R ${TEX_EXT_DIR-$(1)}
endef
define download_repo
$(foreach file,${TEX_EXT_FILES-$(1)},\
  $(eval $(notdir ${file}): ${TEX_EXT_DIR-$(1)}/${file}))
$(notdir ${TEX_EXT_FILES-$(1)}):
	${LN} $$^ $$@
.PHONY: $(1)
$(1): $(notdir ${TEX_EXT_FILES-$(1)})
$(addprefix ${TEX_EXT_DIR-$(1)}/,${TEX_EXT_FILES-$(1)}): \
  ${TEX_EXT_DIR-$(1)}/${TEX_EXT_SRC-$(1)}
$(addprefix ${TEX_EXT_DIR-$(1)}/,${TEX_EXT_FILES-$(1)}):
	${LN} ${TEX_EXT_SRC-$(1)}/$${@:${TEX_EXT_DIR-$(1)}/%=%} $$@
${TEX_EXT_DIR-$(1)}/${TEX_EXT_SRC-$(1)}:
	git clone ${TEX_EXT_URL-$(1)} $$@
.PHONY: distclean clean-$(1)
distclean: clean-$(1)
clean-$(1):
	${RM} ${TEX_EXT_FILES-$(1)}
	[ "${TEX_EXT_DIR-$(1)}" = "." ] && ${RM} ${TEX_EXT_SRC-$(1)} \
	  || ${RM} -R ${TEX_EXT_DIR-$(1)}
endef
TEX_EXT_FILES-lncs?=  llncs.cls sprmindx.sty splncs03.bst aliascnt.sty remreset.sty
TEX_EXT_DIR-lncs?=    lncs
TEX_EXT_SRC-lncs?=    llncs2e.zip
TEX_EXT_URL-lncs?=    https://resource-cms.springernature.com/springer-cms/rest/v1/content/19238648/data/v1
TEX_EXT_EXTRACT-lncs?=${UNZIP} -u $$< -d ${TEX_EXT_DIR-lncs}

$(eval $(call download_archive,lncs))
.PHONY: llncs
llncs: lncs
TEX_EXT_FILES-biblatex-lncs?= lncs.bbx lncs.cbx lncs.dbx
TEX_EXT_DIR-biblatex-lncs?=   lncs
TEX_EXT_SRC-biblatex-lncs?=   biblatex-lncs
TEX_EXT_URL-biblatex-lncs?=   https://github.com/NorwegianRockCat/biblatex-lncs.git

$(eval $(call download_repo,biblatex-lncs))
rfc.bib:
	${CURL} -o - http://tm.uka.de/~bless/rfc.bib.gz 2>/dev/null \
	  | ${UNCOMPRESS.gz} - > $@ ; \
	${SED} -i "s/@misc/@techreport/" $@

${TEXMF}/tex/latex/rfc.bib:
	mkdir -p ${TEXMF}/tex/latex/
	${CURL} -o - http://tm.uka.de/~bless/rfc.bib.gz 2>/dev/null \
	  | ${UNCOMPRESS.gz} - > $@ ; \
	${SED} -i "s/@misc/@techreport/" $@
.PHONY: rfc
rfc: rfc.bib ${TEXMF}/tex/latex/rfc.bib
.PHONY: distclean clean-rfc
distclean: clean-rfc
clean-rfc:
	${RM} rfc.bib
TEX_EXT_FILES-popets?=by-nc-nd.pdf sciendo-logo.pdf dgruyter_NEW.sty
TEX_EXT_URL-popets?=https://petsymposium.org/files/popets.zip
TEX_EXT_DIR-popets?=popets
TEX_EXT_SRC-popets?=popets.zip
TEX_EXT_EXTRACT-popets?=${UNZIP} -p $$< popets/$$(notdir $$@) > $$@

$(eval $(call download_archive,popets))
.PHONY: clean clean-tex
clean: clean-tex

clean-tex:
	-latexmk -C -output-directory=${TEX_OUTDIR}
	[ "${TEX_OUTDIR}" -ef "$$(pwd)" ] || \
	  ${RM} -R ${TEX_OUTDIR}
	${RM} ${TEX_LATEXMKDIR}/*.latexmklog ${TEX_LATEXMKDIR}/*.latexmkstatus
	${RM} *.pytxcode
	${RM} -R pythontex-files-*

.PHONY: distclean distclean-tex
distclean: distclean-tex

distclean-tex:
	[ ! -L latexmkrc ] || ${RM} latexmkrc

endif
