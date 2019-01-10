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
PDF2PS?=      pdf2ps
PDF2PSFLAGS?=
PS2PDF?=      ps2pdf
PS2PDFFLAGS?=
DVIPS?=       dvips
DVIPSFLAGS?=
ODF2PDF?=     soffice --convert-to pdf
ODF2PDFFLAGS?=--headless
INKSCAPE?=      inkscape
INKSCAPEFLAGS?= -D -z --export-latex
DIA?=           dia
DIAFLAGS?=
XCF2PNGFLAGS?=  -flatten
XCF2PNG?=       convert ${XCF2PNGFLAGS} $< $@
TRIM?=          convert -trim $@ $@
MD2TEX?=        pandoc -f markdown -t latex
MD2TEXFLAGS?=
TEX2TEXT?=      detex
TEX2TEXTFLAGS?=
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
%.ps: %.pdf
	${PDF2PS} ${PDF2PSFLAGS} $<
%.pdf: %.ps
	${PS2PDF} ${PS2PDFFLAGS} $<
%.ps: %.dvi
	${DVIPS} ${DVIPSFLAGS} $<
%.pdf: %.odt
	${ODF2PDF} ${ODF2PDFFLAGS} $<
%.pdf: %.ods
	${ODF2PDF} ${ODF2PDFFLAGS} $<
%.pdf: %.odg
	${ODF2PDF} ${ODF2PDFFLAGS} $<
%.pdf: %.odp
	${ODF2PDF} ${ODF2PDFFLAGS} $<
%.pdf: %.docx
	${ODF2PDF} ${ODF2PDFFLAGS} $<
%.pdf: %.xlsx
	${ODF2PDF} ${ODF2PDFFLAGS} $<
%.pdf: %.pptx
	${ODF2PDF} ${ODF2PDFFLAGS} $<

%.pdf: %.svg
	${INKSCAPE} ${INKSCAPEFLAGS} --file=$< --export-pdf=$@
%.ps: %.svg
	${INKSCAPE} ${INKSCAPEFLAGS} --file=$< --export-ps=$@

%.eps: %.svg
	${INKSCAPE} ${INKSCAPEFLAGS} --file=$< --export-eps=$@
%.tex: %.dia
	${DIA} ${DIAFLAGS} -e $@ -t pgf-tex $<
%.png: %.xcf
	${XCF2PNG}
	${TRIM}

%.tex: %.md
	${MD2TEX} ${MD2TEXFLAGS} < $< > $@
%.txt: %.tex
	${TEX2TEXT} ${TEX2TEXTFLAGS} $< > $@

endif
