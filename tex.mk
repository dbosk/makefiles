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
WC?= 		wc -w

# variables used to compile LaTeX documents
LATEX?=		latex
PDFLATEX?=	pdflatex
DETEX?= 	detex
LATEXMK?= 	latexmk ${LATEXMKRC} -bibtex-cond
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

# $1 = input file
# $2 = output file
define sed_transformations
${CAT} $1 \
	$(shell [ "${solutions}" = "no" ] || echo \
	" | ${SEDex} \"${MATCH_PRINTANSWERS}\" " ) \
	$(shell [ "${handout}" = "no" ] || echo \
	" | ${SEDex} \"${MATCH_HANDOUT}\" " ) \
	> $2
endef

# $1 = latex version
# $2 = input tex file
define run_latex
$1 ${LATEXFLAGS} $2
-${BIBTEX} ${1:.tex=}
-${MAKEINDEX} -s gind.ist ${2:.tex=}
-${MAKEINDEX} ${2:.tex=.nlo} -s nomencl.ist -o ${2:.tex=.nls}
while ($1 ${LATEXFLAGS} $2; \
	grep "Rerun to get cross" ${2:.tex=.log}) \
	do true; done
$1 ${LATEXFLAGS} $2
endef

# $1 = original file
# $2 = new file
# $3 = backup file
define backup_file
if diff -u $1 $2; then \
	mv $1 $3 && mv $2 $1; \
fi
endef

# $1 = backup file
# $2 = original file
define restore_file
if [ -f $1 ]; then \
	${MV} $1 $2; \
fi
endef

.SUFFIXES: .tex
.tex.pdf: latexmk
ifeq (${USE_LATEXMK},yes)
	${LATEXMK} -pdf ${LATEXFLAGS} $<
else
	$(call run_latex, ${PDFLATEX}, $<)
endif

.tex.dvi: latexmk
ifeq (${USE_LATEXMK},yes)
	${LATEXMK} -dvi ${LATEXFLAGS} $<
else
	$(call run_latex, ${PDFLATEX}, $<)
endif

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
	${RM} -R pythontex-files-* *.pytxcode *.py.err
	@-for f in *.tex; do \
		[ -f $$f.orig ] && mv $$f.orig $$f; \
	done
	@-${LATEXMK} -C
	@if [ -L rfc.bib ]; then \
		${RM} rfc.bib; \
	fi

.PHONY: clean
clean: clean-tex

latexmkrc:
	[ -e $@ ] || ln -s ${INCLUDE_MAKEFILES}/latexmkrc $@

.PHONY: clean-latexmkrc
clean-depends: clean-latexmkrc
clean-latexmkrc:
	${RM} latexmkrc

endif
