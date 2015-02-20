# $Id$
# Author: 	Daniel Bosk <daniel.bosk@miun.se>

ifndef DEPEND_MK
DEPEND_MK=true

CONF?= 	${HOME}/.mk.conf
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


latexmkrc:
	wget https://raw.githubusercontent.com/dbosk/makefiles/master/$@

.PHONY: clean-latexmkrc
clean-depends: clean-latexmkrc
clean-latexmkrc:
	${RM} latexmkrc


.PHONY: clean-mk
clean-depends: clean-mk
clean-mk:
	${RM} depend.mk doc.mk export.mk
	${RM} moodle.mk package.mk pub.mk subdir.mk tex.mk
	${RM} miun.course.mk miun.depend.mk miun.docs.mk miun.port.mk


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
	unzip -DD ${LLNCS}/llncs2e.zip ${@:${LLNCS}/=} -d ${LLNCS}

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
	git clone https://github.com/gvdgdo/biblatex-lncs.git biblatex-lncs-src

$(patsubst %,${BIBLATEX-LNCS}/%,${BLTX-files}): biblatex-lncs-src
	cp biblatex-lncs-src/${@:${BIBLATEX-LNCS}/=} $@

.PHONY: biblatex-lncs clean-biblatex-lncs
biblatex-lncs: $(patsubst %,${BIBLATEX-LNCS}/%,${BLTX-files})
clean-depends: clean-biblatex-lncs
clean-biblatex-lncs:
	${RM} $(patsubst %,${BIBLATEX-LNCS}/%,${BLTX-files})
	${RM} -R biblatex-lncs-src

### Springer's Monograph ###

#SVMONO?= 	${TEXMF}/tex/latex/svmono
SVMONO?= 	.

${SVMONO}/svmono.zip:
	wget -O $@ http://static.springer.com/sgw/documents/72921/application/zip/svmono.zip

SVMONO-files= 	svind.ist
SVMONO-files+= 	svmono.cls

$(patsubst %,${SVMONO}/%,${SVMONO-files}): ${SVMONO}/svmono.zip
	unzip -DD ${SVMONO}/svmono.zip styles/${@:${SVMONO}/=} -d ${SVMONO}

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
	unzip -DD ${ACMSMALL}/v2-acmsmall.zip acmsmall.cls -d ${ACMSMALL}

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
	unzip -DD ${ACMLARGE}/v2-acmlarge.zip acmlarge.cls -d ${ACMLARGE}

.PHONY: acmlarge clean-acmlarge
acmlarge: ${ACMLARGE}/acmlarge.cls
clean-depends: clean-acmlarge
clean-acmlarge:
	${RM} ${ACMLARGE}/acmlarge.cls


### libbib ###

LIBBIB+=anon.bib
LIBBIB+=crypto.bib
LIBBIB+=meta.bib
LIBBIB+=otrmsg.bib
LIBBIB+=ppes.bib
LIBBIB+=surveillance.bib

${LIBBIB}: libbib
	#wget -O $@ https://priv-git.csc.kth.se/utilities/libbib/raw/master/$@
	ln -s libbib/$@ ./$@

libbib:
	git clone git@priv-git.csc.kth.se:utilities/libbib.git $@

define check_clean_libbib
[ ! -e libbib ] || ( cd libbib && \
git diff-files --quiet --ignore-submodules -- && \
git diff-index --cached --quiet HEAD --ignore-submodules -- && \
! [ "$$(git diff origin/master..HEAD | wc -l)" -gt 0 ] )
endef

.PHONY: clean-libbib
clean-depends: clean-libbib
clean-libbib:
	${RM} ${LIBBIB}
	$(call check_clean_libbib)
	${RM} -R libbib

endif
