MKFILES+=		  portability.mk subdir.mk
MKFILES+=		  pkg.mk pub.mk transform.mk
MKFILES+=		  tex.mk doc.mk
MKFILES+=		  noweb.mk haskell.mk
MKFILES+=		  exam.mk results.mk

OTHERS+=		  latexmkrc
OTHERS+=		  gitattributes
OTHERS+= 		  Dockerfile

PUB_FILES+=		  makefiles.pdf

.PHONY: all
all: ${PUB_FILES}
all: ${MKFILES}
all: ${OTHERS}

.PHONY: publish
publish: gh-release

Makefile: Makefile.nw
	${NOTANGLE.mk}
Dockerfile: Dockerfile.nw
	${NOTANGLE}
LATEXFLAGS+=    -shell-escape
TEX_PYTHONTEX=  yes
makefiles.pdf: makefiles.tex preamble.tex makefiles.bib
makefiles.pdf: intro.tex Makefile.tex
makefiles.pdf: exam.bib
makefiles.pdf: transform.bib
makefiles.pdf: tex.bib
makefiles.pdf: Dockerfile.tex
define makefiles_depends
makefiles.pdf: $(1:.mk=.tex)
$(1) $(1:.mk=.tex): $(1).nw
endef

$(foreach mkfile,${MKFILES},$(eval $(call makefiles_depends,${mkfile})))
latexmkrc: tex.mk.nw
	${NOTANGLE}

gitattributes: transform.mk.nw
	${NOTANGLE}
DOCKER_ID_USER?=dbosk

.PHONY: docker-makefiles push
docker-makefiles: Dockerfile
	docker build -t makefiles .
	docker tag makefiles ${DOCKER_ID_USER}/makefiles

push: docker-makefiles
	docker push ${DOCKER_ID_USER}/makefiles
PKG_PACKAGES?=			    main
PKG_NAME-main= 			    makefiles

PKG_PREFIX=				      /usr/local
PKG_INSTALL_DIR=		    /include

PKG_INSTALL_FILES-main=	${MKFILES}
PKG_TARBALL_FILES-main=	${PKG_INSTALL_FILES-main} ${OTHERS} Makefile README.md

.PHONY: all
all: makefiles.tar.gz
.PHONY: clean distclean
clean:
	${RM} makefiles.pdf
	${RM} Dockerfile.tex
	${RM} ${MKFILES:.mk=.tex}
	${RM} gitattributes
	${RM} makefiles.tar.gz

distclean:
	docker image rm makefiles
	docker image rm dbosk/makefiles
INCLUDE_MAKEFILES=.
MAKEFILES_INCLUDE=${INCLUDE_MAKEFILES}
include ${MAKEFILES_INCLUDE}/tex.mk
include ${MAKEFILES_INCLUDE}/noweb.mk
include ${MAKEFILES_INCLUDE}/pkg.mk
include ${MAKEFILES_INCLUDE}/pub.mk
