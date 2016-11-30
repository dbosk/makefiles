ifndef TEX_MK
TEX_MK=true

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
TEX_LNCS?=    lncs
LNCS-files+=  llncs.cls
LNCS-files+=  sprmindx.sty
LNCS-files+=  splncs03.bst
LNCS-files+=  aliascnt.sty
LNCS-files+=  remreset.sty
BIBLTX-files= 	lncs.bbx
BIBLTX-files+= 	lncs.cbx
BIBLTX-files+= 	lncs.dbx
TEX_BIBLATEX-LNCS?=   .
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
ifneq (${TEX_IND},)
%.pdf: ${TEX_OUTDIR}/%.ind
endif
ifneq (${TEX_PYTHONTEX},)
%.pdf: ${TEX_OUTDIR}/pythontex-files-%/%.pytxcode
endif
${TEX_OUTDIR}/%.idx: %.tex
	${MKDIR} ${TEX_OUTDIR}
	${PDFLATEX} -output-directory=${TEX_OUTDIR} ${LATEXFLAGS} $<
${TEX_OUTDIR}/%.ind: ${TEX_OUTDIR}/%.idx
	${XINDY} -o $@ ${XINDYFLAGS} $<
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
.PHONY: clean clean-tex
clean: clean-tex

clean-tex:
	-latexmk -C -output-directory=${TEX_OUTDIR}

.PHONY: distclean distclean-tex
distclean: distclean-tex

distclean-tex:
	${RM} latexmkrc

endif
