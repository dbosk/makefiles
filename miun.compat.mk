ifndef MIUN_COMPAT_MK
MIUN_COMPAT_MK=true

INCLUDE_MAKEFILES?=.
include ${INCLUDE_MAKEFILES}/subdir.mk
ifndef MIUN_PACKAGE_MK
MIUN_PACKAGE_MK=true

ifdef TARBALL_NAME
PKG_TARBALL?=${TARBALL_NAME}.tar.gz
endif

ifdef DOCS_FILES
PKG_PACKAGES=	 main docs

PKG_INSTALL_FILES-docs?=${DOCS_FILES}
PKG_INSTALL_DIR-docs?=${DOCSDIR}
endif

.PHONY: all
all: package

INCLUDE_MAKEFILES?=.
include ${INCLUDE_MAKEFILES}/pkg.mk

endif # MIUN_PACKAGE_MK
ifndef MIUN_PUB_MK
MIUN_PUB_MK=true

SERVER?=		ver.miun.se
PUBDIR?=		/srv/web/svn
CATEGORY?=
TMPDIR?=		/var/tmp
PUB_GROUP?= svn

ifdef NO_COMMIT
PUB_AUTOCOMMIT?=${NO_COMMIT}
endif

ifdef COMMIT_OPTS
PUB_COMMIT_OPTS?=${COMMIT_OPTS}
endif

INCLUDE_MAKEFILES?=.
include ${INCLUDE_MAKEFILES}/pub.mk

endif # MIUN_PUB_MK
ifndef MIUN_EXPORT_MK
MIUN_EXPORT_MK=true

TRANSFORM_SRC=    .tex
TRANSFORM_DST=    .exporttex

TRANSFORM_LIST.exporttex=         NoSolutions
TRANSFORM_LIST-Makefile.export=   OldExportFilter ExportFilter

INCLUDE_MAKEFILES?=.
include ${INCLUDE_MAKEFILES}/transform.mk

endif # MIUN_EXPORT_MK
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
ifndef MIUN_DOCS_MK
MIUN_DOCS_MK=true

DOCUMENTS?=
PUB_FILES?=   ${DOCUMENTS}
SERVER?=      ver.miun.se
PUBDIR?=      /srv/web/svn/dokument
CATEGORY?=	

ifdef PRINT
LPR?=         ${PRINT}
endif

.PHONY: all
all: ${DOCUMENTS}

.PHONY: print
print: ${DOCUMENTS:.pdf=.ps}

.PHONY: clean-docs
clean-docs:
ifneq (${DOCUMENTS},)
	${RM} ${DOCUMENTS}
endif

.PHONY: clean
clean: clean-docs

.PHONY: todo
todo: $(wildcard *)

INCLUDE_MAKEFILES?=.
include ${INCLUDE_MAKEFILES}/miun.tex.mk
include ${INCLUDE_MAKEFILES}/miun.pub.mk

endif # MIUN_DOCS_MK
ifndef MIUN_COURSE_MK
MIUN_COURSE_MK=true

DOCUMENTS?=
PUB_FILES?=   ${DOCUMENTS}
SERVER?=      ver.miun.se
PUBDIR?=      /srv/web/svn/courses
CATEGORY?=	

.PHONY: all
all: ${DOCUMENTS}

.PHONY: clean-course
clean-course:
ifneq (${DOCUMENTS},)
	${RM} ${DOCUMENTS}
endif

.PHONY: clean
clean: clean-course

INCLUDE_MAKEFILES?=.
include ${INCLUDE_MAKEFILES}/miun.docs.mk
include ${INCLUDE_MAKEFILES}/miun.export.mk

endif # MIUN_COURSE_MK
ifndef MIUN_RESULTS_MK
MIUN_RESULTS_MK=true

in?=              ${COURSE}.txt
out?=              reported.csv
report?=          new_results.pdf

RESULTS_COURSE?=  ${COURSE}
RESULTS_EMAIL?=   ${EXPADDR}

MAILER?=	thunderbird -compose \
  "to=${EXPADDR},subject='resultat ${COURSE}',attachment='file://${report}'"
RESULTS_MAILER?=  ${MAILER}

REWRITES?=	"s/Godkänd(G)/G/g" "s/Underkänd(U)/U/g" "s/Komplettering(Fx)/Fx/g"
RESULTS_REWRITES?=${REWRITES}

FAILED?=	-\|Fx\?\|U
RESULTS_FAILED?=  ${FAILED}

FAILED_regex=	"	\(${FAILED}\)\(	.*\)*$$"
RESULTS_FAILED_regex?=${FAILED_regex}

INCLUDE_MAKEFILES?=.
include ${INCLUDE_MAKEFILES}/results.mk

endif # MIUN_RESULTS_MK
ifndef MIUN_DEPEND_MK
MIUN_DEPEND_MK=true

CONF?= 	/etc/mk.conf
-include ${CONF}

.PHONY: dvips
ifeq (${MAKE},gmake)
dvips:
	which dvips || sudo pkg_add ghostscript
else
dvips:
	which dvips || sudo apt-get install texlive-full
endif

.PHONY: pdf2ps
ifeq (${MAKE},gmake)
pdf2ps:
	which pdf2ps || sudo pkg_add ghostscript
else
pdf2ps:
	which pdf2ps || sudo apt-get install texlive-full
endif

.PHONY: latex
ifeq (${MAKE},gmake)
latex:
	which latex || sudo pkg_add texlive_texmf-full
else
latex:
	which latex || sudo apt-get install texlive-full
endif

.PHONY: latexmk
ifeq (${MAKE},gmake)
latexmk:
	which latexmk || sudo pkg_add latexmk
else
latexmk:
	which latexmk || sudo apt-get install latexmk
endif

.PHONY: pax
ifeq (${MAKE},gmake)
pax:
	which pax
else
pax:
	which pax || sudo apt-get install pax
endif

.PHONY: sed
ifeq (${MAKE},gmake)
SED= 	gsed
SEDex= 	gsed -E
sed gsed:
	which gsed || sudo pkg_add gsed
else
sed gsed:
	which sed
endif

.PHONY: grep
ifeq (${MAKE},gmake)
GREP= 		ggrep
GREPex= 	ggrep -E
grep ggrep:
	which ggrep || sudo pkg_add ggrep
else
grep ggrep:
	which grep
endif

.PHONY: git
ifeq (${MAKE},gmake)
git:
	which git || sudo pkg_add git git-svn
else
git:
	which git || sudo apt-get install git git-svn
endif

.PHONY: wget
ifeq (${MAKE},gmake)
wget:
	which wget || sudo pkg_add wget
else
wget:
	which wget || sudo apt-get install wget
endif

.PHONY: localc
ifeq (${MAKE},gmake)
localc:
	which localc || sudo pkg_add libreoffice
else
localc:
	which localc || sudo apt-get install libreoffice
endif

.PHONY: update

update: update-rfc

.PHONY: rfc remove-rfc update-rfc clean-rfc

rfc: rfc.bib

remove-rfc::
	${RM} -f ${TEXMF}/tex/latex/rfc.bib

update-rfc: remove-rfc ${TEXMF}/tex/latex/rfc.bib

.PHONY: clean-depends
#clean: clean-depends
clean-depends: clean-rfc
clean-rfc:
	${RM} rfc.bib

${TEXMF}/tex/latex/rfc.bib: ${wget-depend}
	mkdir -p ${TEXMF}/tex/latex/
	wget -O - http://tm.uka.de/~bless/rfc.bib.gz 2>/dev/null | \
		uncompress - > ${@}

rfc.bib:
	if [ -e ${TEXMF}/tex/latex/rfc.bib ]; then \
		ln -s ${TEXMF}/tex/latex/rfc.bib rfc.bib ; \
	else \
		wget -O - http://tm.uka.de/~bless/rfc.bib.gz 2>/dev/null | \
		uncompress - > ${@} ; \
	fi


update: latexmkrc miun.tex.mk miun.course.mk miun.docs.mk
update: miun.export.mk miun.pub.mk miun.package.mk
update: miun.subdir.mk miun.results.mk

latexmkrc miun.tex.mk \
miun.course.mk miun.docs.mk miun.export.mk miun.pub.mk \
miun.package.mk miun.subdir.mk miun.results.mk:
	wget -O $@ http://ver.miun.se/build/$@

clean-depends:
	${RM} latexmkrc miun.tex.mk miun.course.mk miun.docs.mk miun.export.mk
	${RM} miun.pub.mk miun.package.mk miun.subdir.mk miun.results.mk

update: miunmisc miunart miunasgn miunbeam miunexam
update: miunlett miunprot miunthes

### MIUN Miscellanous package and Logo ###

miunmisc-depend?= 	${TEXMF}/tex/latex/miun/miunmisc/miunmisc.sty
logo-depend?=		${TEXMF}/tex/latex/miun/miunmisc/MU_logotyp_int_sv.eps \
					${TEXMF}/tex/latex/miun/miunmisc/MU_logotyp_int_CMYK.eps

${miunmisc-depend} ${logo-depend}:
	wget -O /tmp/miunmisc.tar.gz \
		http://ver.miun.se/latex/packages/miunmisc.tar.gz
	cd /tmp && tar -zxf miunmisc.tar.gz
	cd /tmp/miunmisc && ${MAKE} install

#.PHONY: miunmisc miunlogo
#miunmisc: ${miunmisc-depend}
#miunlogo: miunmisc

### MIUN Article class ###

miunart-depend?= 	${TEXMF}/tex/latex/miun/miunart/miunart.sty
${miunart-depend}:
	wget -O /tmp/miunart.tar.gz \
		http://ver.miun.se/latex/packages/miunart.tar.gz
	cd /tmp && tar -zxf miunart.tar.gz
	cd /tmp/miunart && ${MAKE} install

#.PHONY: miunart
#miunart: ${miunart-depend} miunlogo

### MIUN Assignment class ###

miunasgn-depend?= 	${TEXMF}/tex/latex/miun/miunasgn/miunasgn.sty
${miunasgn-depend}:
	wget -O /tmp/miunasgn.tar.gz \
		http://ver.miun.se/latex/packages/miunasgn.tar.gz
	cd /tmp && tar -zxf miunasgn.tar.gz
	cd /tmp/miunasgn && ${MAKE} install

#.PHONY: miunasgn
#miunasgn: ${miunasgn-depend} miunlogo

### MIUN Beamer class ###

miunbeam-depend?= 	${TEXMF}/tex/latex/miun/miunbeam/miunbeam.sty
${miunbeam-depend}:
	wget -O /tmp/miunbeam.tar.gz \
		http://ver.miun.se/latex/packages/miunbeam.tar.gz
	cd /tmp && tar -zxf miunbeam.tar.gz
	cd /tmp/miunbeam && ${MAKE} install

#.PHONY: miunbeam
#miunbeam: ${miunbeam-depend} miunlogo

### MIUN Exam class ###

miunexam-depend?= 	${TEXMF}/tex/latex/miun/miunexam/miunexam.sty
${miunexam-depend}:
	wget -O /tmp/miunexam.tar.gz \
		http://ver.miun.se/latex/packages/miunexam.tar.gz
	cd /tmp && tar -zxf miunexam.tar.gz
	cd /tmp/miunexam && ${MAKE} install

#.PHONY: miunexam
#miunexam: ${miunexam-depend} miunlogo

### MIUN Letter class ###

miunlett-depend?= 	${TEXMF}/tex/latex/miun/miunlett/miunlett.sty
${miunlett-depend}:
	wget -O /tmp/miunlett.tar.gz \
		http://ver.miun.se/latex/packages/miunlett.tar.gz
	cd /tmp && tar -zxf miunlett.tar.gz
	cd /tmp/miunlett && ${MAKE} install

#.PHONY: miunlett
#miunlett: ${miunlett-depend} miunlogo

### MIUN Protocol class ###

miunprot-depend?= 	${TEXMF}/tex/latex/miun/miunprot/miunprot.sty
${miunprot-depend}:
	wget -O /tmp/miunprot.tar.gz \
		http://ver.miun.se/latex/packages/miunprot.tar.gz
	cd /tmp && tar -zxf miunprot.tar.gz
	cd /tmp/miunprot && ${MAKE} install

#.PHONY: miunprot
#miunprot: ${miunprot-depend} miunlogo

### MIUN Thesis class ###

miunthes-depend?= 	${TEXMF}/tex/latex/miun/miunthes/miunthes.sty
${miunthes-depend}:
	wget -O /tmp/miunthes.tar.gz \
		http://ver.miun.se/latex/packages/miunthes.tar.gz
	cd /tmp && tar -zxf miunthes.tar.gz
	cd /tmp/miunthes && ${MAKE} install

#.PHONY: miunthes
#miunthes: ${miunthes-depend} miunlogo

endif # MIUN_DEPEND_MK

endif
