ifndef TEX_MK
TEX_MK=true

INCLUDE_MAKEFILES?=.
include ${INCLUDE_MAKEFILES}/portability.mk

LATEX?=       latexmk -dvi
PDFLATEX?=    latexmk -pdf
LATEXFLAGS?=
TEX_OUTDIR?=  ltxobj
TEX_BBL?=
BIBTEX?=      bibtexu
BIBTEXFLAGS?=
BIBER?=       biber
BIBERFLAGS?=
TEX_IND?=
MAKEINDEX?=   makeindex
MAKEIDXFLAGS?=
XINDY?=       texindy
XINDYFLAGS?=
TEX_PYTHONTEX?=
PYTHONTEX?=   pythontex3
PYTHONTEXFLAGS?=
TEX_EXT_DIR-acmproc?=     acm
${TEX_OUTDIR}/%.aux: %.tex
	${MKDIR} ${TEX_OUTDIR}
	${PDFLATEX} -output-directory=${TEX_OUTDIR} ${LATEXFLAGS} $<
${TEX_OUTDIR}/%.bbl: ${TEX_OUTDIR}/%.aux
	${BIBTEX} ${BIBTEXFLAGS} $<
	${MV} $@ ${@:.bbl=.blg} ${TEX_OUTDIR}
${TEX_OUTDIR}/%.bcf: %.tex
	${MKDIR} ${TEX_OUTDIR}
	${PDFLATEX} -output-directory=${TEX_OUTDIR} ${LATEXFLAGS} $<
${TEX_OUTDIR}/%.bbl: ${TEX_OUTDIR}/%.bcf
	${BIBER} -O $@ ${BIBERFLAGS} $<
ifneq (${TEX_BBL},)
%.pdf: ${TEX_OUTDIR}/%.bbl
endif
ifneq (${TEX_PYTHONTEX},)
%.pdf: ${TEX_OUTDIR}/pythontex-files-%/%.pytxcode
endif
${TEX_OUTDIR}/%.idx: %.tex
	${MKDIR} ${TEX_OUTDIR}
	${PDFLATEX} -output-directory=${TEX_OUTDIR} ${LATEXFLAGS} $<
${TEX_OUTDIR}/%.ind: ${TEX_OUTDIR}/%.idx
	${XINDY} -o $@ ${XINDYFLAGS} $<
ifneq (${TEX_IND},)
%.pdf: ${TEX_OUTDIR}/%.ind
endif
${TEX_OUTDIR}/%.nlo: %.tex
	${MKDIR} ${TEX_OUTDIR}
	${PDFLATEX} -output-directory=${TEX_OUTDIR} ${LATEXFLAGS} $<

${TEX_OUTDIR}/%.nls: ${TEX_OUTDIR}/%.nlo
	${MKDIR} ${TEX_OUTDIR}
	${MAKEINDEX} -o $@ ${MAKEIDXFLAGS} -s nomencl.ist $<
pythontex-files-%/%.pytxcode: %.tex
	${PYTHONTEX} ${PYTHONTEXFLAGS} $<
%.pdf ${TEX_OUTDIR}/%.pdf: %.tex
	${PDFLATEX} -output-directory=${TEX_OUTDIR} ${LATEXFLAGS} $<
	while ( grep "Rerun to get cross" ${TEX_OUTDIR}/${<:.tex=.log} ); do \
	  ${PDFLATEX} -output-directory=${TEX_OUTDIR} ${LATEXFLAGS} $<; \
	done
	-${LN} ${TEX_OUTDIR}/$@ $@

%.dvi ${TEX_OUTDIR}/%.dvi: %.tex
	${LATEX} -output-directory=${TEX_OUTDIR} ${LATEXFLAGS} $<
	while ( grep "Rerun to get cross" ${TEX_OUTDIR}/${<:.tex=.log} ); do \
	  ${LATEX} -output-directory=${TEX_OUTDIR} ${LATEXFLAGS} $<; \
	done
	-${LN} ${TEX_OUTDIR}/$@ $@
latexmkrc:
	[ -e $@ ] || ln -s ${INCLUDE_MAKEFILES}/latexmkrc $@
%.cls %.sty: %.ins
	${LATEX} $<
%.pdf ${TEX_OUTDIR}/%.pdf: %.dtx
	${PDFLATEX} -output-directory=${TEX_OUTDIR} ${LATEXFLAGS} $<
	while ( grep "Rerun to get cross" ${TEX_OUTDIR}/${<:.tex=.log} ); do \
	  ${PDFLATEX} -output-directory=${TEX_OUTDIR} ${LATEXFLAGS} $<; \
	done
	-${LN} ${TEX_OUTDIR}/$@ $@

%.dvi ${TEX_OUTDIR}/%.dvi: %.dtx
	${LATEX} -output-directory=${TEX_OUTDIR} ${LATEXFLAGS} $<
	while ( grep "Rerun to get cross" ${TEX_OUTDIR}/${<:.tex=.log} ); do \
	  ${LATEX} -output-directory=${TEX_OUTDIR} ${LATEXFLAGS} $<; \
	done
	-${LN} ${TEX_OUTDIR}/$@ $@
${TEX_OUTDIR}/%.aux: %.dtx
	${PDFLATEX} -output-directory=${TEX_OUTDIR} ${LATEXFLAGS} $<

${TEX_OUTDIR}/%.bcf: %.dtx
	${PDFLATEX} -output-directory=${TEX_OUTDIR} ${LATEXFLAGS} $<

${TEX_OUTDIR}/%.idx: %.dtx
	${PDFLATEX} -output-directory=${TEX_OUTDIR} ${LATEXFLAGS} $<
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
	[ "${TEX_EXT_DIR-$(1)}" = "." ] || ${RM} -R ${TEX_EXT_DIR-$(1)}
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
	${LN} ${TEX_EXT_DIR-$(1)}/${TEX_EXT_SRC-$(1)}/$${@:${TEX_EXT_DIR-$(1)}/%=%} $$@
${TEX_EXT_DIR-$(1)}/${TEX_EXT_SRC-$(1)}:
	git clone ${TEX_EXT_URL-$(1)} $$@
.PHONY: distclean clean-$(1)
distclean: clean-$(1)
clean-$(1):
	${RM} ${TEX_EXT_FILES-$(1)}
	[ "${TEX_EXT_DIR-$(1)}" = "." ] || ${RM} -R ${TEX_EXT_DIR-$(1)}
endef
TEX_EXT_FILES-lncs?=  llncs.cls sprmindx.sty splncs03.bst aliascnt.sty remreset.sty
TEX_EXT_DIR-lncs?=    lncs
TEX_EXT_SRC-lncs?=    llncs2e.zip
TEX_EXT_URL-lncs?=    ftp://ftp.springer.de/pub/tex/latex/llncs/latex2e/llncs2e.zip
TEX_EXT_EXTRACT-lncs?=${UNZIP} $< -d ${TEX_EXT_DIR-lncs}

$(eval $(call download_archive,lncs))
TEX_EXT_FILES-biblatex-lncs?= lncs.bbx lncs.cbx lncs.dbx
TEX_EXT_DIR-biblatex-lncs?=   lncs
TEX_EXT_SRC-biblatex-lncs?=   biblatex-lncs
TEX_EXT_URL-biblatex-lncs?=   https://github.com/neapel/biblatex-lncs.git

$(eval $(call download_repo,biblatex-lncs))
${TEX_EXT_DIR-acmproc}/acm_proc_article-sp.cls:
	${CURL} -o $@ http://www.acm.org/sigs/publications/acm_proc_article-sp.cls
acm_proc_article-sp.cls: ${TEX_EXT_DIR-acmproc}/acm_proc_article-sp.cls
	${LN} $^ $@
.PHONY: acmproc
acmproc: acm_proc_article-sp.cls
.PHONY: distclean clean-acmproc
distclean: clean-acmproc
clean-acmproc:
	${RM} acm_proc_article-sp.cls
	${RM} ${TEX_EXT_DIR-acmproc}/acm_proc_article-sp.cls
TEX_EXT_FILES-acmsmall?=  acmsmall.cls
TEX_EXT_DIR-acmsmall?=    acm
TEX_EXT_SRC-acmsmall?=    v2-acmsmall.zip
TEX_EXT_URL-acmsmall?=    http://www.acm.org/publications/latex_style/v2-acmsmall.zip
TEX_EXT_EXTRACT-acmsmall?=${UNZIP} $< -d ${TEX_EXT_DIR-acmsmall}

$(eval $(call download_archive,acmsmall))
TEX_EXT_FILES-acmlarge?=  acmlarge.cls
TEX_EXT_DIR-acmlarge?=    acm
TEX_EXT_SRC-acmlarge?=    v2-acmlarge.zip
TEX_EXT_URL-acmlarge?=    http://www.acm.org/publications/latex_style/v2-acmlarge.zip
TEX_EXT_EXTRACT-acmlarge?=${UNZIP} $< -d ${TEX_EXT_DIR-acmlarge}

$(eval $(call download_archive,acmlarge))
rfc.bib:
	${CURL} -o - http://tm.uka.de/~bless/rfc.bib.gz 2>/dev/null \
	  | ${UNCOMPRESS} - > $@ ; \
	${SED} -i "s/@misc/@techreport/" $@

${TEXMF}/tex/latex/rfc.bib:
	mkdir -p ${TEXMF}/tex/latex/
	${CURL} -o - http://tm.uka.de/~bless/rfc.bib.gz 2>/dev/null \
	  | ${UNCOMPRESS} - > $@ ; \
	${SED} -i "s/@misc/@techreport/" $@
.PHONY: rfc
rfc: rfc.bib ${TEXMF}/tex/latex/rfc.bib
.PHONY: distclean clean-rfc
distclean: clean-rfc
clean-rfc:
	${RM} rfc.bib
.PHONY: clean clean-tex
clean: clean-tex

clean-tex:
	-latexmk -C -output-directory=${TEX_OUTDIR}

.PHONY: distclean distclean-tex
distclean: distclean-tex

distclean-tex:
	${RM} latexmkrc

endif
