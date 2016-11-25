ifndef TEX_MK
TEX_MK=true

include ${INCLUDE_MAKEFILES}/portability.mk

LATEX?=       latexmk
PDFLATEX?=    latexmk -pdf
LATEXFLAGS?=
TEX_OUTDIR?=  ltxobj
VPATH+=       ${TEX_OUTDIR}
BIBTEX?=      bibtexu
BIBTEXFLAGS?=
BIBER?=       biber
BIBERFLAGS?=
MAKEINDEX?=   makeindex
MAKEIDXFLAGS?=-s gind.ist
PYTHONTEX?=   pythontex3
PYTHONTEXFLAGS?=
${TEX_OUTDIR}/%.aux: %.tex
	${LATEX} -output-directory=${TEX_OUTDIR} ${LATEXFLAGS} $<
${TEX_OUTDIR}/%.bcf: %.tex
	${LATEX} -output-directory=${TEX_OUTDIR} ${LATEXFLAGS} $<

${TEX_OUTDIR}/%.bbl: %.aux
	cd ${TEX_OUTDIR} && ${BIBTEX} ${BIBTEXFLAGS} ../$<

${TEX_OUTDIR}/%.bbl: %.bcf
	${BIBER} -O $@ ${BIBERFLAGS} $<
${TEX_OUTDIR}/%.idx: %.tex
	${LATEX} -output-directory=${TEX_OUTDIR} ${LATEXFLAGS} $<

${TEX_OUTDIR}/%.ind: ${TEX_OUTDIR}/%.idx
	${MAKEINDEX} -o $@ ${MAKEIDXFLAGS} $<

${TEX_OUTDIR}/%.nlo: %.tex
	${LATEX} -output-directory=${TEX_OUTDIR} ${LATEXFLAGS} $<

${TEX_OUTDIR}/%.nls: ${TEX_OUTDIR}/%.nlo
	${MAKEINDEX} -o $@ ${MAKEIDXFLAGS} -s nomencl.ist $<
pythontex-files-%/%.pytxmcr: %.tex
	${PYTHONTEX} ${PYTHONTEXFLAGS} $<
%.pdf: %.tex
	${PDFLATEX} -output-directory=${TEX_OUTDIR} ${LATEXFLAGS} $<
	while ( grep "Rerun to get cross" ${TEX_OUTDIR}/${<:.tex=.log} ); do \
	  ${PDFLATEX} -output-directory=${TEX_OUTDIR} ${LATEXFLAGS} $<; \
	done

%.dvi: %.tex
	${LATEX} -output-directory=${TEX_OUTDIR} ${LATEXFLAGS} $<
	while ( grep "Rerun to get cross" ${TEX_OUTDIR}/${<:.tex=.log} ); do \
	  ${LATEX} -output-directory=${TEX_OUTDIR} ${LATEXFLAGS} $<; \
	done
latexmkrc:
	[ -e $@ ] || ln -s ${INCLUDE_MAKEFILES}/latexmkrc $@
.SUFFIXES: .ins .cls .sty
.ins.sty .ins.cls:
	${LATEX} $<
%.pdf: %.dtx
	${PDFLATEX} -output-directory=${TEX_OUTDIR} ${LATEXFLAGS} $<
	while ( grep "Rerun to get cross" ${TEX_OUTDIR}/${<:.tex=.log} ); do \
	  ${PDFLATEX} -output-directory=${TEX_OUTDIR} ${LATEXFLAGS} $<; \
	done

%.dvi:
	${LATEX} -output-directory=${TEX_OUTDIR} ${LATEXFLAGS} $<
	while ( grep "Rerun to get cross" ${TEX_OUTDIR}/${<:.tex=.log} ); do \
	  ${LATEX} -output-directory=${TEX_OUTDIR} ${LATEXFLAGS} $<; \
	done
%.aux: %.dtx
	${LATEX} -output-directory=${TEX_OUTDIR} ${LATEXFLAGS} $<

%.bbl: %.aux
	cd ${TEX_OUTDIR} && ${BIBTEX} ${BIBTEXFLAGS} ../$<

%.bcf: %.dtx
	

%.bbl: %.bcf
	${BIBER} -O $@ ${BIBERFLAGS} $<
.PHONY: clean clean-tex
clean: clean-tex

clean-tex:
	-${LATEXMK} -C

.PHONY: distclean distclean-tex
distclean: distclean-tex

distclean-tex:
	${RM} latexmkrc

endif
