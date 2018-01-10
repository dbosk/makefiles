MKFILES+=		portability.mk subdir.mk
MKFILES+=		pkg.mk pub.mk transform.mk
MKFILES+=		tex.mk doc.mk
MKFILES+=		noweb.mk haskell.mk
MKFILES+=		exam.mk results.mk
MKFILES+=		miun.compat.mk

MIUNFILES+=		miun.docs.mk miun.tex.mk miun.subdir.mk
MIUNFILES+=		miun.package.mk miun.pub.mk miun.course.mk
MIUNFILES+=		miun.export.mk miun.results.mk miun.depend.mk

OTHERS+=		latexmkrc
OTHERS+=		gitattributes

.PHONY: all
all: makefiles.pdf
all: ${MKFILES}
all: ${MIUNFILES}
all: ${OTHERS}

makefiles.pdf: makefiles.tex preamble.tex intro.tex makefiles.bib
makefiles.pdf: exam.bib
makefiles.pdf: transform.bib
makefiles.pdf: tex.bib

define makefiles_depends
makefiles.pdf: $(1:.mk=.tex)
$(1) $(1:.mk=.tex): $(1).nw
endef

$(foreach mkfile,${MKFILES},$(eval $(call makefiles_depends,${mkfile})))

latexmkrc: tex.mk.nw
	notangle -t2 -R$@ $^ | cpif $@

gitattributes: transform.mk.nw
	notangle -t2 -R$@ $^ | cpif $@


miun.compat.tex: miun.compat.mk.nw

${MIUNFILES}: miun.compat.mk.nw
	${NOTANGLE.mk}


.PHONY: clean
clean:
	${RM} makefiles.pdf
	${RM} makefiles.tar.gz
	${RM} portability.tex
	${RM} subdir.tex
	${RM} pkg.tex
	${RM} transform.tex
	${RM} gitattributes
	${RM} pub.tex
	${RM} tex.tex
	${RM} doc.tex
	${RM} noweb.tex
	${RM} haskell.tex
	${RM} exam.tex
	${RM} results.tex
	${RM} miun.compat.tex


.PHONY: miun
miun: ${MIUNFILES}

PKG_PACKAGES?= 			main miun

PKG_PREFIX=				/usr/local
PKG_INSTALL_DIR=		/include

PKG_NAME-main= 			makefiles
PKG_INSTALL_FILES-main=	${MKFILES}
PKG_TARBALL_FILES-main=	${PKG_INSTALL_FILES-main} ${OTHERS} Makefile README.md

PKG_NAME-miun=			build-all
PKG_INSTALL_FILES-miun=	${MIUNFILES}
PKG_TARBALL_FILES-miun=	${PKG_INSTALL_FILES-miun} ${OTHERS} Makefile README.md


INCLUDE_MAKEFILES=.
include ${INCLUDE_MAKEFILES}/portability.mk
include ${INCLUDE_MAKEFILES}/noweb.mk
include ${INCLUDE_MAKEFILES}/tex.mk
include ${INCLUDE_MAKEFILES}/pkg.mk
