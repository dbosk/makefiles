# $Id$
# Author: Daniel Bosk <daniel.bosk@miun.se>

ifndef TEX_MK
TEX_MK=true

DOCUMENTS?=	
TEXMF?=		${HOME}/texmf

solutions?=	no
handout?=	no

RM?=		/bin/rm -f
MV?=		mv
SED?=		sed
SEDex?=		sed -E
CAT?=		cat

# variables used to compile LaTeX documents
LATEX?=		latex
PDFLATEX?=	pdflatex
LATEXMK?= 	latexmk ${LATEXMKRC}
LATEXMKRC?= 
DVIPS?=		dvips
PDFPS?=		pdf2ps
LATEXFLAGS?=
MAKEINDEX?=	makeindex
BIBTEX?=	bibtex8
PDFVIEW?=	evince
PAPER?=		a4

USE_LATEXMK?= 	yes
USE_BIBLATEX?= 	yes

MATCH_PRINTANSWERS="/\\\\\\\\\\printanswers/s/^%//"
MATCH_HANDOUT="s/\\\\\\\\\\documentclass\\[?(.*)\\]?{beamer}/\\\\\\\\\\documentclass\\[\\1,handout\\]{beamer}/"

.SUFFIXES: .ins .cls .sty
.ins.sty .ins.cls: latex
	${LATEX} $<

.SUFFIXES: .dtx .pdf
.dtx.pdf: latex
	${PDFLATEX} ${LATEXFLAGS} $<
ifneq (${USE_BIBLATEX},yes)
	-${BIBTEX} ${<:.dtx=}
endif
	-${MAKEINDEX} -s gind.ist ${<:.dtx=}
	-${MAKEINDEX} ${<:.dtx=.nlo} -s nomencl.ist -o ${<:.dtx=.nls}
	while (${PDFLATEX} ${LATEXFLAGS} $<; \
		grep "Rerun to get cross" ${<:.dtx=.log}) \
		do true; done
	${PDFLATEX} ${LATEXFLAGS} $<

.SUFFIXES: .dvi
.dtx.dvi: latex
	${LATEX} ${LATEXFLAGS} $<
ifneq (${USE_BIBLATEX},yes)
	-${BIBTEX} ${<:.dtx=}
endif
	-${MAKEINDEX} -s gind.ist ${<:.dtx=}
	-${MAKEINDEX} ${<:.dtx=.nlo} -s nomencl.ist -o ${<:.dtx=.nls}
	while (${LATEX} ${LATEXFLAGS} $<; \
		grep "Rerun to get cross" ${<:.dtx=.log}) \
		do true; done
	${LATEX} ${LATEXFLAGS} $<

.SUFFIXES: .ps
.pdf.ps: pdf2ps
	${PDFPS} $< $@

.SUFFIXES: .tex
.tex.pdf: latexmk
	${CAT} $< \
		$(shell [ "${solutions}" = "no" ] || echo \
		" | ${SEDex} \"${MATCH_PRINTANSWERS}\" " ) \
		$(shell [ "${handout}" = "no" ] || echo \
		" | ${SEDex} \"${MATCH_HANDOUT}\" " ) \
		> $<.new
	if diff -u $< $<.new; then \
		mv $< $<.orig && mv $<.new $<; \
	fi
ifeq (${USE_LATEXMK},yes)
	${LATEXMK} -pdf ${LATEXFLAGS} ${<:.tex=}
else
	${PDFLATEX} ${LATEXFLAGS} $<
ifneq (${USE_BIBLATEX},yes)
	-${BIBTEX} ${<:.tex=}
endif
	-${MAKEINDEX} -s gind.ist ${<:.tex=}
	-${MAKEINDEX} ${<:.tex=.nlo} -s nomencl.ist -o ${<:.tex=.nls}
	while (${PDFLATEX} ${LATEXFLAGS} $<; \
		grep "Rerun to get cross" ${<:.tex=.log}) \
		do true; done
	${PDFLATEX} ${LATEXFLAGS} $<
endif
	if [ -f $<.orig ]; then \
		${MV} $<.orig $<; \
	fi

.tex.dvi: latexmk
	${CAT} $< \
		$(shell [ "${solutions}" = "no" ] || echo \
		" | ${SEDex} \"${MATCH_PRINTANSWERS}\" " ) \
		$(shell [ "${handout}" = "no" ] || echo \
		" | ${SEDex} \"${MATCH_HANDOUT}\" " ) \
		> $<.new
	if diff -u $< $<.new; then \
		mv $< $<.orig && mv $<.new $<; \
	fi
ifeq (${USE_LATEXMK},yes)
	${LATEXMK} -dvi ${LATEXFLAGS} ${<:.tex=}
else
	${LATEX} ${LATEXFLAGS} $<
ifneq (${USE_BIBLATEX},yes)
	-${BIBTEX} ${<:.tex=}
endif
	-${MAKEINDEX} -s gind.ist ${<:.tex=}
	-${MAKEINDEX} ${<:.tex=.nlo} -s nomencl.ist -o ${<:.tex=.nls}
	while (${LATEX} ${LATEXFLAGS} $<; \
		grep "Rerun to get cross" ${<:.tex=.log}) \
		do true; done
	${LATEX} ${LATEXFLAGS} $<
endif
	if [ -f $<.orig ]; then \
		${MV} $<.orig $<; \
	fi

.dvi.ps: dvips
	${DVIPS} $<

.SUFFIXES: .svg
.svg.tex: inkscape
	inkscape -D -z --file=$< --export-pdf=${@:.tex=.pdf} --export-latex
	mv ${@:.tex=.pdf_tex} $@

.SUFFIXES: .dia
.dia.tex: dia
	dia -E $@ -t pgf-tex $<

.SUFFIXES: .odt
.odt.pdf: soffice
	soffice --convert-to pdf $< --headless

.PHONY: all
all: ${DOCUMENTS}

.PHONY: clean-tex
clean-tex: latexmk
	${RM} *.log *.aux *.toc *.bbl *.blg *.ind *.ilg *.dvi
	${RM} *.out *.idx *.nls *.nlo *.lof *.lot *.glo
	${RM} *.core *.o *~ *.out
	${RM} missfont.log *.nav *.snm *.vrb *-eps-converted-to.pdf
	${RM} *.run.xml *-blx.bib
	${RM} *.bcf *.fdb_latexmk *.fls
	@-for f in *.tex; do \
		[ -f $$f.orig ] && mv $$f.orig $$f; \
	done
	@-${LATEXMK} -C
	@if [ -L rfc.bib ]; then \
		${RM} rfc.bib; \
	fi

.PHONY: clean
clean: clean-tex

filecontent = for f in $(1); do ${SED} -i \
	"/^%\\\\begin{filecontents\\*\\?}{$$f}/,/^%\\\\end{filecontents\\*\\?}/s/^%//" $(2); \
	${SED} -i "/^\\\\begin{filecontents\\*\\?}{$$f}/r $$f" $(2); done

bibliography = ${SED} -i -e "/\\\\bibliography{[^}]*}/{s/\\\\bibliography.*//;r $(1:.tex=.bbl)" -e "}" $(1)

bblcode = "\\\\makeatletter\\\\def\\\\blx@bblfile@biber{\\\\blx@secinit\\\\begingroup\\\\blx@bblstart\\\\input{\\\\jobname.bbl}\\\\blx@bblend\\\\endgroup\\\\csnumgdef{blx@labelnumber@\\\\the\\\\c@refsection}{0}}\\\\makeatother"

.SUFFIXES: .submission.tex
.tex.submission.tex: sed
	cp $< $@
	eval '$(call filecontent,\
		$(shell ${SED} -n \
		"s/^%\\\\begin{filecontents\\*\\?}{\\([^}]*\\)}/\\1/p" \
		$<),$@)'
	eval '$(call bibliography,$@)'
	${SED} -i "s/^%biblatex-bbl-code/${bblcode}/" $@
	${SED} -i "s/${@:.tex=}/\\\\jobname/g" $@

.SUFFIXES: .submission.bbl .bbl
.bbl.submission.bbl:
	cp $< $@

.PHONY: submission
submission: ${DOCUMENTS:.pdf=.submission.tex}

.SUFFIXES: .py.nw .c.nw .h.nw .cpp.nw .hpp.nw .mk.nw
.py.nw.tex .c.nw.tex .h.nw.tex .cpp.nw.tex .hpp.nw.tex .mk.nw.tex: noweb
	noweave -x -n -delay -t2 $< > $@

### INCLUDES ###

INCLUDE_MAKEFILES?= .
INCLUDES= 	depend.mk

define inc
ifeq ($(findstring $(1),${MAKEFILE_LIST}),)
$(1):
	wget https://raw.githubusercontent.com/dbosk/makefiles/master/$(1)
include ${INCLUDE_MAKEFILES}/$(1)
endif
endef
$(foreach i,${INCLUDES},$(eval $(call inc,$i)))

endif
