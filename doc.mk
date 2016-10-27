ifndef DOC_MK
DOC_MK=true

DOC_LPR?=		lpr
DOC_WC?=    wc -w
PDF2PS?=        pdf2ps
PDFPS?=         ${PDF2PS}
DOC_PDF2PS?=    ${PDFPS}
DVIPS?=         dvips
DOC_DVI2PS?=    ${DVIPS}
DOC_ODT2PDF?=   soffice --headless --convert-to pdf
DOC_INKSCAPE_FLAGS?=  -D -z --export-latex
DOC_DIA_FLAGS?=
DOC_MD2TEX?=    pandoc -f markdown -t latex
DOC_TEX2TEXT?=  detex
.PHONY: print
print:
	$(foreach doc,$^,${DOC_LPR} ${doc})
.PHONY: wc
wc:
	$(foreach doc,$^,echo -n "${doc}: "; ${DOC_WC} ${doc})
.SUFFIXES: .ps .pdf
.pdf.ps:
	${DOC_PDF2PS} $<
.SUFFIXES: .dvi .ps
.dvi.ps:
	${DOC_DVI2PS} $<
.SUFFIXES: .odt .pdf
.odt.pdf:
	${DOC_ODT2PDF} $<

.SUFFIXES: .svg .pdf
.svg.pdf:
	inkscape ${DOC_INKSCAPE_FLAGS} --file=$< --export-pdf=$@
.SUFFIXES: .dia .tex
.dia.tex:
	dia ${DOC_DIA_FLAGS} -e $@ -t pgf-tex $<

.SUFFIXES: .md .tex
.md.tex:
	${DOC_MD2TEX} < $< > $@
.SUFFIXES: .tex .txt
.tex.txt:
	${DOC_TEX2TEXT} $< > $@

endif
