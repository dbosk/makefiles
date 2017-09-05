ifndef DOC_MK
DOC_MK=true

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
	${ODT2PDF} ${ODT2PDFFLAGS} $<

%.pdf: %.svg
	${INKSCAPE} ${INKSCAPEFLAGS} --file=$< --export-pdf=$@
%.ps: %.svg
	${INKSCAPE} ${INKSCAPEFLAGS} --file=$< --export-ps=$@

%.eps: %.svg
	${INKSCAPE} ${INKSCAPEFLAGS} --file=$< --export-eps=$@
%.tex: %.dia
	${DIA} ${DIAFLAGS} -e $@ -t pgf-tex $<

%.tex: %.md
	${MD2TEX} ${MD2TEXFLAGS} < $< > $@
%.txt: %.tex
	${TEX2TEXT} ${TEX2TEXTFLAGS} $< > $@

endif
