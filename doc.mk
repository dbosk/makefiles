ifndef DOC_MK
DOC_MK=true

INCLUDE_MAKEFILES?=.
include ${INCLUDE_MAKEFILES}/portability.mk

LPR?=       lpr
LPRFLAGS?=
WC?=        wc
WCFLAGS?=   -w
TODO?=        ${GREP} "\(XXX\|TODO\|FIXME\)"
TODOFLAGS?=
PDF2PS?=          pdf2ps
PDF2PSFLAGS?=
CONVERT.pdf.ps?=  ${PDF2PS} ${PDF2PSFLAGS} $<

PS2PDF?=          ps2pdf
PS2PDFFLAGS?=
CONVERT.ps.pdf?=  ${PS2PDF} ${PS2PDFFLAGS} $<
DVIPS?=           dvips
DVIPSFLAGS?=
CONVERT.dvi.ps?=  ${DVIPS} ${DVIPSFLAGS} $<
ODF2PDF?=         soffice --convert-to pdf
ODF2PDFFLAGS?=    --headless
CONVERT.odt.pdf?= ${ODF2PDF} ${ODF2PDFFLAGS} $<
CONVERT.ods.pdf?= ${ODF2PDF} ${ODF2PDFFLAGS} $<
CONVERT.odg.pdf?= ${ODF2PDF} ${ODF2PDFFLAGS} $<
CONVERT.odp.pdf?= ${ODF2PDF} ${ODF2PDFFLAGS} $<
CONVERT.doc.pdf?= ${ODF2PDF} ${ODF2PDFFLAGS} $<
CONVERT.docx.pdf?=${ODF2PDF} ${ODF2PDFFLAGS} $<
CONVERT.xls.pdf?= ${ODF2PDF} ${ODF2PDFFLAGS} $<
CONVERT.xlsx.pdf?=${ODF2PDF} ${ODF2PDFFLAGS} $<
CONVERT.ppt.pdf?= ${ODF2PDF} ${ODF2PDFFLAGS} $<
CONVERT.pptx.pdf?=${ODF2PDF} ${ODF2PDFFLAGS} $<
INKSCAPE?=        inkscape
INKSCAPEFLAGS?=   -D -z --export-latex
CONVERT.svg.pdf?= ${INKSCAPE} ${INKSCAPEFLAGS} --file=$< --export-pdf=$@
CONVERT.svg.ps?=  ${INKSCAPE} ${INKSCAPEFLAGS} --file=$< --export-ps=$@
CONVERT.svg.eps?= ${INKSCAPE} ${INKSCAPEFLAGS} --file=$< --export-eps=$@
DIA?=             dia
DIAFLAGS?=
CONVERT.dia.tex?= ${DIA} ${DIAFLAGS} -e $@ -t pgf-tex $<
XCF2PNGFLAGS?=    -flatten
XCF2PNG?=         convert ${XCF2PNGFLAGS} $< $@
TRIM?=            convert -trim $@ $@
CONVERT.xcf.png?= ${XCF2PNG} && ${TRIM}
MD2TEX?=        pandoc
MD2TEXFLAGS?=   -s
CONVERT.md.tex?=${MD2TEX} ${MD2TEXFLAGS} -o $@ $<

TEX2MD?=        pandoc
TEX2MDFLAGS?=   -s
CONVERT.tex.md?=${TEX2MD} ${TEX2MDFLAGS} -o $@ $<
MD2HTML?=           pandoc
MD2HTMLFLAGS?=      -s
CONVERT.md.html?=   ${MD2HTML} ${MD2HTMLFLAGS} -o $@ $<

TEX2HTML?=          pandoc
TEX2HTMLFLAGS?=     -s
CONVERT.tex.html?=  ${TEX2HTML} ${TEX2HTMLFLAGS} -o $@ $<
TEX2TEXT?=        detex
TEX2TEXTFLAGS?=
CONVERT.tex.txt?= ${TEX2TEXT} ${TEX2TEXTFLAGS} -o $@ $<
.PHONY: print
print:
	$(foreach doc,$^,\
	  $(if ${LPR-${doc}},${LPR-${doc}},${LPR}) \
	  $(if ${LPRFLAGS-${doc}},${LPRFLAGS-${doc}},${LPRFLAGS}) \
	  ${doc};)
.PHONY: wc
wc:
	$(foreach doc,$^,echo -n "${doc}: "; ${CAT} ${doc} | \
	  $(if ${PREWC-${doc}},${PREWC-${doc}} |,$(if ${PREWC},${PREWC} |,)) \
	  $(if ${WC-${doc}},${WC-${doc}},${WC}) \
	  $(if ${WCFLAGS-${doc}},${WCFLAGS-${doc}},${WCFLAGS});)
.PHONY: todo
todo:
	$(foreach doc,$^,echo "${doc}: "; ${CAT} ${doc} | \
	  $(if ${PRETODO-${doc}},${PRETODO-${doc}} |,$(if ${PRETODO},${PRETODO} |,)) \
	  $(if ${TODO-${doc}},${TODO-${doc}},${TODO}) \
	  $(if ${TODOFLAGS-${doc}},${TODOFLAGS-${doc}},${TODOFLAGS});echo;)
%.pdf: %.ps
	${CONVERT.ps.pdf}
%.ps: %.dvi
	${CONVERT.dvi.ps}
define def_convert_rule
%.pdf: %.$(1)
	${CONVERT.$(1).pdf}
endef
$(foreach suf,odt ods odg odp doc docx xls xlsx ppt pptx,\
  $(eval $(call def_convert_rule,${suf})))

%.pdf: %.svg
	${CONVERT.svg.pdf}
%.ps %.eps: %.svg
	${CONVERT.svg$(suffix $@)}
%.tex: %.dia
	${CONVERT.dia.tex}
%.png: %.xcf
	${CONVERT.xcf.png}

%.md: %.tex
	${CONVERT.tex.md}
define to_html_rule
%.html: %.$(1)
	${CONVERT.$(1).html}
endef
$(foreach suf,md tex,$(eval $(call to_html_rule,${suf})))
%.txt: %.tex
	${CONVERT.tex.txt}

endif
