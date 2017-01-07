# $Id$
# Author: 	Daniel Bosk <daniel.bosk@miun.se>

ifndef DEPEND_MK
DEPEND_MK=true

CONF?= 	${HOME}/.mk.conf /etc/mk.conf
-include ${CONF}

ifeq ($(shell uname),Linux)
UNZIP?= unzip -DD
else
UNZIP?= unzip
endif

.PHONY: dvips
ifeq (${MAKE},gmake)
dvips:
	which dvips || sudo pkg_add ghostscript
else
dvips:
	which dvips || sudo apt install texlive-full
endif

.PHONY: pdf2ps
ifeq (${MAKE},gmake)
pdf2ps:
	which pdf2ps || sudo pkg_add ghostscript
else
pdf2ps:
	which pdf2ps || sudo apt install texlive-full
endif

.PHONY: latex
ifeq (${MAKE},gmake)
latex:
	which latex || sudo pkg_add texlive_texmf-full
else
latex:
	which latex || sudo apt install texlive-full
endif

.PHONY: latexmk
ifeq (${MAKE},gmake)
latexmk:
	which latexmk || sudo pkg_add latexmk
else
latexmk:
	which latexmk || sudo apt install latexmk
endif

.PHONY: pax
ifeq (${MAKE},gmake)
pax:
	which pax
else
pax:
	which pax || sudo apt install pax
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
	which git || sudo apt install git git-svn
endif

.PHONY: wget
ifeq (${MAKE},gmake)
wget:
	which wget || sudo pkg_add wget
else
wget:
	which wget || sudo apt install wget
endif

.PHONY: localc
ifeq (${MAKE},gmake)
localc:
	which localc || sudo pkg_add libreoffice
else
localc:
	which localc || sudo apt install libreoffice
endif

.PHONY: soffice
ifeq (${MAKE},gmake)
soffice:
	which soffice || sudo pkg_add libreoffice
else
soffice:
	which soffice || sudo apt install libreoffice
endif

.PHONY: dia
ifeq (${MAKE},gmake)
dia:
	which dia || sudo pkg_add dia
else
dia:
	which dia || sudo apt install dia
endif

.PHONY: inkscape
ifeq (${MAKE},gmake)
inkscape:
	which inkscape || sudo pkg_add inkscape 
else
inkscape:
	which inkscape || sudo apt install inkscape
endif

.PHONY: noweb
ifeq (${MAKE},gmake)
noweb:
	which noweb || sudo pkg_add noweb 
else
noweb:
	which noweb || sudo apt install noweb
endif

.PHONY: pandoc
ifeq (${MAKE},gmake)
pandoc:
	which pandoc || sudo pkg_add pandoc
else
pandoc:
	which pandoc || sudo apt install pandoc
endif


.PHONY: update

update: update-rfc

.PHONY: rfc remove-rfc update-rfc clean-rfc

rfc: rfc.bib

remove-rfc::
	${RM} -f ${TEXMF}/tex/latex/rfc.bib

update-rfc: remove-rfc ${TEXMF}/tex/latex/rfc.bib

.PHONY: clean-depends
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
	sed -i "s/@misc/@manual/" $@


latexmkrc:
	if [ -e ${INCLUDE_MAKEFILES}/latexmkrc ]; then \
		ln -s ${INCLUDE_MAKEFILES}/latexmkrc $@ ; \
	else \
		wget https://raw.githubusercontent.com/dbosk/makefiles/master/$@ ; \
	fi

.PHONY: clean-latexmkrc
clean-depends: clean-latexmkrc
clean-latexmkrc:
	${RM} latexmkrc


.PHONY: clean-mk
clean-depends: clean-mk
clean-mk:
	find depend.mk doc.mk export.mk moodle.mk package.mk pub.mk subdir.mk \
		tex.mk miun.course.mk miun.depend.mk miun.docs.mk miun.port.mk -type l \
		| xargs ${RM}


### Springer's Lecture Notes on Computer Science ###

#LLNCS?=${TEXMF}/tex/latex/llncs
LLNCS?= .

${LLNCS}/llncs2e.zip:
	wget -O $@ ftp://ftp.springer.de/pub/tex/latex/llncs/latex2e/llncs2e.zip

LLNCS-files= 	llncs.cls
LLNCS-files+= 	sprmindx.sty
LLNCS-files+= 	splncs03.bst
LLNCS-files+= 	aliascnt.sty
LLNCS-files+= 	remreset.sty

$(patsubst %,${LLNCS}/%,${LLNCS-files}): ${LLNCS}/llncs2e.zip
	${UNZIP} ${LLNCS}/llncs2e.zip ${@:${LLNCS}/=} -d ${LLNCS}

.PHONY: llncs clean-llncs
llncs: ${LLNCS-files}
clean-depends: clean-llncs
clean-llncs:
	${RM} $(patsubst %,${LLNCS}/%,${LLNCS-files}) ${LLNCS}/llncs2e.zip


#BIBLATEX-LNCS?=	${TEXMF}/tex/latex/biblatex
BIBLATEX-LNCS?= .
BLTX-files= 	lncs.bbx
BLTX-files+= 	lncs.cbx
BLTX-files+= 	lncs.dbx

biblatex-lncs-src:
	if [ -e biblatex-lncs ]; then \
		ln -s biblatex-lncs biblatex-lncs-src; \
	else \
		git clone https://github.com/neapel/biblatex-lncs.git \
		biblatex-lncs-src; \
	fi

$(patsubst %,${BIBLATEX-LNCS}/%,${BLTX-files}): biblatex-lncs-src
	[ -e $@ ] || ln -s biblatex-lncs-src/${@:${BIBLATEX-LNCS}/=} $@

.PHONY: biblatex-lncs clean-biblatex-lncs
biblatex-lncs: $(patsubst %,${BIBLATEX-LNCS}/%,${BLTX-files})
clean-depends: clean-biblatex-lncs
clean-biblatex-lncs:
	find $(patsubst %,${BIBLATEX-LNCS}/%,${BLTX-files}) -type l | \
		xargs ${RM}
	${RM} -R biblatex-lncs-src

### Springer's Monograph ###

#SVMONO?= 	${TEXMF}/tex/latex/svmono
SVMONO?= 	.

${SVMONO}/svmono.zip:
	wget -O $@ http://static.springer.com/sgw/documents/72921/application/zip/svmono.zip

SVMONO-files= 	svind.ist
SVMONO-files+= 	svmono.cls

$(patsubst %,${SVMONO}/%,${SVMONO-files}): ${SVMONO}/svmono.zip
	${UNZIP} ${SVMONO}/svmono.zip styles/${@:${SVMONO}/=} -d ${SVMONO}

.PHONY: svmono clean-svmono
svmono: $(patsubst %,${SVMONO}/%,${SVMONO-files})
clean-depends: clean-svmono
clean-svmono:
	${RM} $(patsubst %,${SVMONO}/%,${SVMONO-files})

### ACM SIG Proceedings ###

#ACMSIG?= 	${TEXMF}/tex/latex/acm/proc
ACMSIG?= 	.

${ACMSIG}/acm_proc_article-sp.cls:
	wget -O $@ http://www.acm.org/sigs/publications/acm_proc_article-sp.cls

.PHONY: acmproc clean-acmproc
acmproc: ${ACMSIG}/acm_proc_article-sp.cls
clean-depends: clean-acmproc
clean-acmproc:
	${RM} ${ACMSIG}/acm_proc_article-sp.cls

### ACM Small Standard ###

#ACMSMALL?= 	${TEXTMF}/tex/latex/acm/small
ACMSMALL?= 		.

${ACMSMALL}/v2-acmsmall.zip:
	wget -O $@ http://www.acm.org/publications/latex_style/v2-acmsmall.zip

${ACMSMALL}/acmsmall.cls: ${ACMSMALL}/v2-acmsmall.zip
	${UNZIP} ${ACMSMALL}/v2-acmsmall.zip acmsmall.cls -d ${ACMSMALL}

.PHONY: acmsmall clean-acmsmall
acmsmall: ${ACMSMALL}/acmsmall.cls
clean-depends: clean-acmsmall
clean-acmsmall:
	${RM} ${ACMSMALL}/acmsmall.cls

### ACM Large Standard ###

#ACMLARGE?= 	${TEXTMF}/tex/latex/acm/large
ACMLARGE?= 		.

${ACMLARGE}/v2-acmlarge.zip:
	wget -O $@ http://www.acm.org/publications/latex_style/v2-acmlarge.zip

${ACMLARGE}/acmlarge.cls: ${ACMLARGE}/v2-acmlarge.zip
	${UNZIP} ${ACMLARGE}/v2-acmlarge.zip acmlarge.cls -d ${ACMLARGE}

.PHONY: acmlarge clean-acmlarge
acmlarge: ${ACMLARGE}/acmlarge.cls
clean-depends: clean-acmlarge
clean-acmlarge:
	${RM} ${ACMLARGE}/acmlarge.cls

endif
