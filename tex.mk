ifndef TEX_MK
TEX_MK=true

.NOTPARALLEL:

INCLUDE_MAKEFILES?=.
include ${INCLUDE_MAKEFILES}/portability.mk

LATEX?=           latexmk -dvi -use-make
PDFLATEX?=        latexmk -pdf -use-make
LATEXFLAGS?=
PREPROCESS.tex?=  ${PDFLATEX} ${LATEXFLAGS} $<
PREPROCESS.dtx?=  ${PREPROCESS.tex}
TEX_OUTDIR?=      ltxobj
COMPILE.tex?=     \
  ${PDFLATEX} ${LATEXFLAGS} -output-directory=${TEX_OUTDIR} $<; \
  while (grep "Rerun to get cross" ${TEX_OUTDIR}/${<:.tex=.log}); \
    do ${PDFLATEX} ${LATEXFLAGS} -output-directory=${TEX_OUTDIR} $<; \
  done
COMPILE.dtx?=     ${COMPILE.tex}
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
	${MV} $@ ${@:.bbl=.blg} ${TEX_OUTDIR}
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
%.pytxmcr ${TEX_OUTDIR}/%.pytxmcr:: ${TEX_OUTDIR}/%.pytxcode
	cd ${TEX_OUTDIR} && ${PYTHONTEX} ${PYTHONTEXFLAGS} $(basename $(notdir $@))
%.pdf ${TEX_OUTDIR}/%.pdf: %.tex
	${COMPILE.tex}
	-${LN} ${TEX_OUTDIR}/$@ $@

%.dvi ${TEX_OUTDIR}/%.dvi: %.tex
	${LATEX} -output-directory=${TEX_OUTDIR} ${LATEXFLAGS} $<
	while ( grep "Rerun to get cross" ${TEX_OUTDIR}/${<:.tex=.log} ); do \
	  ${LATEX} -output-directory=${TEX_OUTDIR} ${LATEXFLAGS} $<; \
	done
	-${LN} ${TEX_OUTDIR}/$@ $@
latexmkrc:
	[ -e $@ -o "${INCLUDE_MAKEFILES}" = "." ] || \
	${LN} -s ${INCLUDE_MAKEFILES}/latexmkrc $@
%.cls %.sty: %.ins
	${LATEX} $<
%.pdf ${TEX_OUTDIR}/%.pdf: %.dtx
	${COMPILE.dtx}
	-${LN} ${TEX_OUTDIR}/$@ $@

%.dvi ${TEX_OUTDIR}/%.dvi: %.dtx
	${LATEX} -output-directory=${TEX_OUTDIR} ${LATEXFLAGS} $<
	while ( grep "Rerun to get cross" ${TEX_OUTDIR}/${<:.tex=.log} ); do \
	  ${LATEX} -output-directory=${TEX_OUTDIR} ${LATEXFLAGS} $<; \
	done
	-${LN} ${TEX_OUTDIR}/$@ $@
${TEX_OUTDIR}/%.aux ${TEX_OUTDIR}/%.bcf ${TEX_OUTDIR}/%.idx: %.dtx
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
	${RM} *.pytxcode
	${RM} -R pythontex-files-*

.PHONY: distclean distclean-tex
distclean: distclean-tex

distclean-tex:
	[ ! -L latexmkrc ] || ${RM} latexmkrc

endif
