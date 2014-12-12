# $Id$
# Author: 	Daniel Bosk <daniel.bosk@miun.se>

ifndef MIUN_DEPEND_MK
MIUN_DEPEND_MK=true

CONF?= 	/etc/mk.conf
-include ${CONF}


.PHONY: update
update: miun.tex.mk miun.course.mk miun.docs.mk
update: miun.export.mk miun.pub.mk miun.package.mk
update: miun.subdir.mk miun.results.mk

miun.tex.mk \
miun.course.mk miun.docs.mk miun.export.mk miun.pub.mk \
miun.package.mk miun.subdir.mk miun.results.mk:
	wget -O $@ http://ver.miun.se/build/$@

.PHONY: clean-depends clean-miun-depends
clean-depends: clean-miun-depends
clean-miun-depends:
	${RM} miun.tex.mk miun.course.mk miun.docs.mk miun.export.mk
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

.PHONY: miunmisc miunlogo
miunmisc: ${miunmisc-depend}
miunlogo: miunmisc

### MIUN Article class ###

miunart-depend?= 	${TEXMF}/tex/latex/miun/miunart/miunart.sty
${miunart-depend}:
	wget -O /tmp/miunart.tar.gz \
		http://ver.miun.se/latex/packages/miunart.tar.gz
	cd /tmp && tar -zxf miunart.tar.gz
	cd /tmp/miunart && ${MAKE} install

.PHONY: miunart
miunart: ${miunart-depend} miunlogo

### MIUN Assignment class ###

miunasgn-depend?= 	${TEXMF}/tex/latex/miun/miunasgn/miunasgn.sty
${miunasgn-depend}:
	wget -O /tmp/miunasgn.tar.gz \
		http://ver.miun.se/latex/packages/miunasgn.tar.gz
	cd /tmp && tar -zxf miunasgn.tar.gz
	cd /tmp/miunasgn && ${MAKE} install

.PHONY: miunasgn
miunasgn: ${miunasgn-depend} miunlogo

### MIUN Beamer class ###

miunbeam-depend?= 	${TEXMF}/tex/latex/miun/miunbeam/miunbeam.sty
${miunbeam-depend}:
	wget -O /tmp/miunbeam.tar.gz \
		http://ver.miun.se/latex/packages/miunbeam.tar.gz
	cd /tmp && tar -zxf miunbeam.tar.gz
	cd /tmp/miunbeam && ${MAKE} install

.PHONY: miunbeam
miunbeam: ${miunbeam-depend} miunlogo

### MIUN Exam class ###

miunexam-depend?= 	${TEXMF}/tex/latex/miun/miunexam/miunexam.sty
${miunexam-depend}:
	wget -O /tmp/miunexam.tar.gz \
		http://ver.miun.se/latex/packages/miunexam.tar.gz
	cd /tmp && tar -zxf miunexam.tar.gz
	cd /tmp/miunexam && ${MAKE} install

.PHONY: miunexam
miunexam: ${miunexam-depend} miunlogo

### MIUN Letter class ###

miunlett-depend?= 	${TEXMF}/tex/latex/miun/miunlett/miunlett.sty
${miunlett-depend}:
	wget -O /tmp/miunlett.tar.gz \
		http://ver.miun.se/latex/packages/miunlett.tar.gz
	cd /tmp && tar -zxf miunlett.tar.gz
	cd /tmp/miunlett && ${MAKE} install

.PHONY: miunlett
miunlett: ${miunlett-depend} miunlogo

### MIUN Protocol class ###

miunprot-depend?= 	${TEXMF}/tex/latex/miun/miunprot/miunprot.sty
${miunprot-depend}:
	wget -O /tmp/miunprot.tar.gz \
		http://ver.miun.se/latex/packages/miunprot.tar.gz
	cd /tmp && tar -zxf miunprot.tar.gz
	cd /tmp/miunprot && ${MAKE} install

.PHONY: miunprot
miunprot: ${miunprot-depend} miunlogo

### MIUN Thesis class ###

miunthes-depend?= 	${TEXMF}/tex/latex/miun/miunthes/miunthes.sty
${miunthes-depend}:
	wget -O /tmp/miunthes.tar.gz \
		http://ver.miun.se/latex/packages/miunthes.tar.gz
	cd /tmp && tar -zxf miunthes.tar.gz
	cd /tmp/miunthes && ${MAKE} install

.PHONY: miunthes
miunthes: ${miunthes-depend} miunlogo latexmkrc


### INCLUDES ###

INCLUDES= 	depend.mk

define inc
ifeq ($(findstring $(1),${MAKEFILE_LIST}),)
$(1):
	wget https://raw.githubusercontent.com/dbosk/makefiles/master/$@
include $(1)
endif
endef
$(foreach i,${INCLUDES},$(eval $(call inc,$i)))

### END INCLUDES ###

endif
