ifndef DOC_MK
DOC_MK=true

LPR?=       lpr
LPRFLAGS?=
WC?=        wc
WCFLAGS?=   -w
PDF2PS?=      pdf2ps
PDF2PSFLAGS?=
PS2PDF?=      ps2pdf
PS2PDFFLAGS?=
DVIPS?=       dvips
DVIPSFLAGS?=
ODT2PDF?=     soffice --convert-to pdf
ODT2PDFFLAGS?=--headless
INKSCAPE?=      inkscape
INKSCAPEFLAGS?= -D -z --export-latex
DIA?=           dia
DIAFLAGS?=
MD2TEX?=        pandoc -f markdown -t latex
MD2TEXFLAGS?=
TEX2TEXT?=      detex
TEX2TEXTFLAGS?=
.PHONY: print
print:
	$(foreach doc,$^,\
	  $(if ${LPR-${doc}},${LPR-${doc}},${LPR}) \
	  $(if ${LPRFLAGS-${doc}},${LPRFLAGS-${doc}},${LPRFLAGS}) \
	  ${doc})
.PHONY: wc
wc:
	$(foreach doc,$^,echo -n "${doc}: "; \
	  $(if ${WC-${doc}},${WC-${doc}},${WC}) \
	  $(if ${WCFLAGS-${doc}},${WCFLAGS-${doc}},${WCFLAGS}) \
	  ${doc})
.SUFFIXES: .ps .pdf
.pdf.ps:
	${PDF2PS} ${PDF2PSFLAGS} $<
.SUFFIXES: .ps .pdf
.ps.pdf:
	${PS2PDF} ${PS2PDFFLAGS} $<
.SUFFIXES: .dvi .ps
.dvi.ps:
	${DVIPS} ${DVIPSFLAGS} $<
.SUFFIXES: .odt .pdf
.odt.pdf:
	${ODT2PDF} ${ODT2PDFFLAGS} $<

.SUFFIXES: .svg .pdf
.svg.pdf:
	${INKSCAPE} ${INKSCAPEFLAGS} --file=$< --export-pdf=$@
.SUFFIXES: .dia .tex
.dia.tex:
	${DIA} ${DIAFLAGS} -e $@ -t pgf-tex $<

.SUFFIXES: .md .tex
.md.tex:
	${MD2TEX} ${MD2TEXFLAGS} < $< > $@
.SUFFIXES: .tex .txt
.tex.txt:
	${TEX2TEXT} ${TEX2TEXTFLAGS} $< > $@

endif
