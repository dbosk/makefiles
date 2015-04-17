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

# Don't use these, better take them from GitHub
#miun.tex.mk \
#miun.course.mk miun.docs.mk miun.export.mk miun.pub.mk \
#miun.package.mk miun.subdir.mk miun.results.mk:
#	wget -O $@ http://ver.miun.se/build/$@

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

MIUNMISC_FILES= 	MU_logotyp_int_CMYK.eps MU_logotyp_int_CMYK.pdf
MIUNMISC_FILES+= 	MU_logotyp_int_sv.eps MU_logotyp_int_sv.pdf
MIUNMISC_FILES+= 	miunmisc.ins miunmisc.dtx

${MIUNMISC_FILES}:
	wget -O $@ http://ver.miun.se/latex/miunmisc/$@

miunmisc.pdf miunmisc.ps: miunmisc.dtx
miunmisc.sty miunmisc-Swedish.dict miunmisc-English.dict: miunmisc.ins
miunmisc.sty miunmisc-Swedish.dict miunmisc-English.dict: miunmisc.dtx

.PHONY: miunmisc miunlogo
miunlogo: MU_logotyp_int_CMYK.eps MU_logotyp_int_CMYK.pdf
miunlogo: MU_logotyp_int_sv.eps MU_logotyp_int_sv.pdf

miunmisc: miunmisc.sty miunmisc-English.dict miunmisc-Swedish.dict
miunmisc: miunlogo

.PHONY: clean-miunmisc clean-miunlogo
clean-depends: clean-miunmisc clean-miunlogo
clean-miunmisc: clean-tex
	${RM} ${MIUNMISC_FILES}
	${RM} miunmisc.sty miunmisc-English.dict miunmisc-Swedish.dict
clean-miunlogo:
	${RM} MU_logotyp_int_CMYK.eps MU_logotyp_int_CMYK.pdf
	${RM} MU_logotyp_int_sv.eps MU_logotyp_int_sv.pdf


### MIUN Article class ###

miunart-depend?= 	${TEXMF}/tex/latex/miun/miunart/miunart.sty
${miunart-depend}:
	wget -O /tmp/miunart.tar.gz \
		http://ver.miun.se/latex/packages/miunart.tar.gz
	cd /tmp && tar -zxf miunart.tar.gz
	cd /tmp/miunart && ${MAKE} install

miunart.cls miunart-English.dict miunart-Swedish.dict:
	wget -O $@ http://ver.miun.se/latex/miunart/$@

.PHONY: miunart
miunart: miunart.cls miunart-English.dict miunart-Swedish.dict miunlogo

.PHONY: clean-miunart
clean-depends: clean-miunart
clean-miunart:
	${RM} miunart.cls miunart-English.dict miunart-Swedish.dict


### MIUN Assignment class ###

miunasgn-depend?= 	${TEXMF}/tex/latex/miun/miunasgn/miunasgn.sty
${miunasgn-depend}:
	wget -O /tmp/miunasgn.tar.gz \
		http://ver.miun.se/latex/packages/miunasgn.tar.gz
	cd /tmp && tar -zxf miunasgn.tar.gz
	cd /tmp/miunasgn && ${MAKE} install

miunasgn.cls miunasgn-English.dict miunasgn-Swedish.dict:
	wget -O $@ http://ver.miun.se/latex/miunasgn/$@

.PHONY: miunasgn
miunasgn: miunasgn.cls miunasgn-Swedish.dict miunasgn-English.dict miunlogo

.PHONY: clean-miunasgn
clean-depends: clean-miunasgn
clean-miunasgn:
	${RM} miunasgn.cls miunasgn-English.dict miunasgn-Swedish.dict


#### MIUN Beamer class ###
#
#miunbeam-depend?= 	${TEXMF}/tex/latex/miun/miunbeam/miunbeam.sty
#${miunbeam-depend}:
#	wget -O /tmp/miunbeam.tar.gz \
#		http://ver.miun.se/latex/packages/miunbeam.tar.gz
#	cd /tmp && tar -zxf miunbeam.tar.gz
#	cd /tmp/miunbeam && ${MAKE} install
#
#.PHONY: miunbeam
#miunbeam: ${miunbeam-depend} miunlogo


### MIUN Exam class ###

miunexam-depend?= 	${TEXMF}/tex/latex/miun/miunexam/miunexam.sty
${miunexam-depend}:
	wget -O /tmp/miunexam.tar.gz \
		http://ver.miun.se/latex/packages/miunexam.tar.gz
	cd /tmp && tar -zxf miunexam.tar.gz
	cd /tmp/miunexam && ${MAKE} install

miunexam.cls miunexam-English.dict miunexam-Swedish.dict:
	wget -O $@ http://ver.miun.se/latex/miunexam/$@

.PHONY: miunexam
miunexam: miunexam.cls miunexam-English.dict miunexam-Swedish.dict
miunexam: miunlogo

.PHONY: clean-miunexam
clean-depends: clean-miunexam
clean-miunexam:
	${RM} miunexam.cls miunexam-English.dict miunexam-Swedish.dict


### MIUN Letter class ###

miunlett-depend?= 	${TEXMF}/tex/latex/miun/miunlett/miunlett.sty
${miunlett-depend}:
	wget -O /tmp/miunlett.tar.gz \
		http://ver.miun.se/latex/packages/miunlett.tar.gz
	cd /tmp && tar -zxf miunlett.tar.gz
	cd /tmp/miunlett && ${MAKE} install

miunlett.cls:
	wget -O $@ http://ver.miun.se/latex/miunlett/$@

.PHONY: miunlett
miunlett: miunlett.cls miunlogo

.PHONY: clean-miunlett
clean-depends: clean-miunlett
clean-miunlett:
	${RM} miunlett.cls


### MIUN Protocol class ###

miunprot-depend?= 	${TEXMF}/tex/latex/miun/miunprot/miunprot.sty
${miunprot-depend}:
	wget -O /tmp/miunprot.tar.gz \
		http://ver.miun.se/latex/packages/miunprot.tar.gz
	cd /tmp && tar -zxf miunprot.tar.gz
	cd /tmp/miunprot && ${MAKE} install

miunprot.cls miunprot-English.dict miunprot-Swedish.dict:
	wget -O $@ http://ver.miun.se/latex/miunprot/$@

.PHONY: miunprot
miunprot: miunprot.cls miunprot-English.dict miunprot-Swedish.dict miunlogo

.PHONY: clean-miunprot
clean-depends: clean-miunprot
clean-miunprot:
	${RM} miunprot.cls miunprot-English.dict miunprot-Swedish.dict


### MIUN Thesis class ###

miunthes-depend?= 	${TEXMF}/tex/latex/miun/miunthes/miunthes.sty
${miunthes-depend}:
	wget -O /tmp/miunthes.tar.gz \
		http://ver.miun.se/latex/packages/miunthes.tar.gz
	cd /tmp && tar -zxf miunthes.tar.gz
	cd /tmp/miunthes && ${MAKE} install

miunthes.cls miunthes-English.dict miunthes-Swedish.dict:
	wget -O $@ http://ver.miun.se/latex/miunthes/$@

.PHONY: miunthes
miunthes: miunthes.cls miunthes-English.dict miunthes-Swedish.dict
miunthes: miunlogo latexmkrc

.PHONY: clean-miunthes
clean-depends: clean-miunthes
clean-miunthes:
	${RM} miunthes.cls miunthes-English.dict miunthes-Swedish.dict


### INCLUDES ###

INCLUDES= 	depend.mk tex.mk

define inc
ifeq ($(findstring $(1),${MAKEFILE_LIST}),)
$(1):
	wget https://raw.githubusercontent.com/dbosk/makefiles/master/$(1)
include $(1)
endif
endef
$(foreach i,${INCLUDES},$(eval $(call inc,$i)))

### END INCLUDES ###

endif
