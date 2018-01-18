ifndef MIUN_TEX_MK
MIUN_TEX_MK=true

TEX_OUTDIR?=  .

TEXMF?=		    ${HOME}/texmf

ifneq (${USE_LATEXMK},yes)
LATEX?=       latex
PDFLATEX?=    pdflatex
endif

ifneq (${USE_BIBLATEX},yes)
TEX_BBL=      yes
endif

solutions?=   no
handout?=     no

TRANSFORM_SRC=  .tex

ifeq (${solutions},yes)
TRANSFORM_DST+= .solutions.tex
TRANSFORM_LIST.solutions.tex=PrintAnswers

%.pdf: %.solutions.pdf
	${LN} $< $@
endif

ifeq (${handout},yes)
TRANSFORM_DST+= .handout.tex
TRANSFORM_LIST.handout.tex=Handout

%.pdf: %.handout.pdf
	${LN} $< $@
endif

.PHONY: all
all: ${DOCUMENTS}

INCLUDE_MAKEFILES?=.
include ${INCLUDE_MAKEFILES}/tex.mk
include ${INCLUDE_MAKEFILES}/transform.mk

endif # MIUN_TEX_MK
