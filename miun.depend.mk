# $Id$
# Author: 	Daniel Bosk <daniel.bosk@miun.se>

ifndef MIUN_DEPEND_MK
MIUN_DEPEND_MK=true

CONF?= 	/etc/mk.conf
-include ${CONF}

CURRENT_URL=https://github.com/dbosk/miuntex/releases/download/v1.0


.PHONY: clean-depends distclean


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
MIUNMISC_FILES+= 	miunmisc.sty miunmisc-Swedish.dict miunmisc-English.dict

${INCLUDE_MIUNTEX}/miunmisc/miunmisc.sty:
	${MAKE} -C ${INCLUDE_MIUNTEX}/miunmisc miunmisc.sty

${INCLUDE_MIUNTEX}/miunmisc/miunmisc-Swedish.dict:
	${MAKE} -C ${INCLUDE_MIUNTEX}/miunmisc miunmisc-Swedish.dict

${INCLUDE_MIUNTEX}/miunmisc/miunmisc-English.dict:
	${MAKE} -C ${INCLUDE_MIUNTEX}/miunmisc miunmisc-English.dict

ifdef INCLUDE_MIUNTEX
$(foreach f,${MIUNMISC_FILES},$(eval $f: ${INCLUDE_MIUNTEX}/miunmisc/$f))
${MIUNMISC_FILES}:
	ln -s $^ $@
else
${MIUNMISC_FILES}:
	wget -O $@ ${CURRENT_URL}/$@
endif

.PHONY: miunmisc miunlogo
miunlogo: MU_logotyp_int_CMYK.eps MU_logotyp_int_CMYK.pdf
miunlogo: MU_logotyp_int_sv.eps MU_logotyp_int_sv.pdf

miunmisc: miunmisc.sty miunmisc-English.dict miunmisc-Swedish.dict
miunmisc: miunlogo

.PHONY: clean-miunmisc clean-miunlogo
clean-depends distclean: clean-miunmisc clean-miunlogo
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

MIUNART_FILES= miunart.cls miunart-English.dict miunart-Swedish.dict

ifdef INCLUDE_MIUNTEX
$(foreach f,${MIUNART_FILES},$(eval $f: ${INCLUDE_MIUNTEX}/miunart/$f))
${MIUNART_FILES}:
	ln -s $^ $@
else
${MIUNART_FILES}:
	wget -O $@ ${CURRENT_URL}/$@
endif

.PHONY: miunart
miunart: ${MIUNART_FILES} miunlogo

.PHONY: clean-miunart
clean-depends distclean: clean-miunart
clean-miunart:
	${RM} ${MIUNART_FILES}


### MIUN Assignment class ###

miunasgn-depend?= 	${TEXMF}/tex/latex/miun/miunasgn/miunasgn.sty
${miunasgn-depend}:
	wget -O /tmp/miunasgn.tar.gz \
		http://ver.miun.se/latex/packages/miunasgn.tar.gz
	cd /tmp && tar -zxf miunasgn.tar.gz
	cd /tmp/miunasgn && ${MAKE} install

MIUNASGN_FILES= miunasgn.cls miunasgn-English.dict miunasgn-Swedish.dict

ifdef INCLUDE_MIUNTEX
$(foreach f,${MIUNASGN_FILES},$(eval $f: ${INCLUDE_MIUNTEX}/miunasgn/$f))
${MIUNASGN_FILES}:
	ln -s $^ $@
else
${MIUNASGN_FILES}:
	wget -O $@ ${CURRENT_URL}/$@
endif

.PHONY: miunasgn
miunasgn: ${MIUNASGN_FILES} miunlogo

.PHONY: clean-miunasgn
clean-depends distclean: clean-miunasgn
clean-miunasgn:
	${RM} ${MIUNASGN_FILES}


### MIUN Exam class ###

miunexam-depend?= 	${TEXMF}/tex/latex/miun/miunexam/miunexam.sty
${miunexam-depend}:
	wget -O /tmp/miunexam.tar.gz \
		http://ver.miun.se/latex/packages/miunexam.tar.gz
	cd /tmp && tar -zxf miunexam.tar.gz
	cd /tmp/miunexam && ${MAKE} install

MIUNEXAM_FILES= miunexam.cls miunexam-English.dict miunexam-Swedish.dict

ifdef INCLUDE_MIUNTEX
$(foreach f,${MIUNEXAM_FILES},$(eval $f: ${INCLUDE_MIUNTEX}/miunexam/$f))
${MIUNEXAM_FILES}:
	ln -s $^ $@
else
${MIUNEXAM_FILES}:
	wget -O $@ ${CURRENT_URL}/$@
endif

.PHONY: miunexam
miunexam: ${MIUNEXAM_FILES} miunlogo

.PHONY: clean-miunexam
clean-depends distclean: clean-miunexam
clean-miunexam:
	${RM} ${MIUNEXAM_FILES}


### MIUN Letter class ###

miunlett-depend?= 	${TEXMF}/tex/latex/miun/miunlett/miunlett.sty
${miunlett-depend}:
	wget -O /tmp/miunlett.tar.gz \
		http://ver.miun.se/latex/packages/miunlett.tar.gz
	cd /tmp && tar -zxf miunlett.tar.gz
	cd /tmp/miunlett && ${MAKE} install

miunlett.cls:
	wget -O $@ ${CURRENT_URL}/$@

.PHONY: miunlett
miunlett: miunlett.cls miunlogo

.PHONY: clean-miunlett
clean-depends distclean: clean-miunlett
clean-miunlett:
	${RM} miunlett.cls


### MIUN Protocol class ###

miunprot-depend?= 	${TEXMF}/tex/latex/miun/miunprot/miunprot.sty
${miunprot-depend}:
	wget -O /tmp/miunprot.tar.gz \
		http://ver.miun.se/latex/packages/miunprot.tar.gz
	cd /tmp && tar -zxf miunprot.tar.gz
	cd /tmp/miunprot && ${MAKE} install

MIUNPROT_FILES= miunprot.cls miunprot-English.dict miunprot-Swedish.dict

ifdef INCLUDE_MIUNTEX
$(foreach f,${MIUNPROT_FILES},$(eval $f: ${INCLUDE_MIUNTEX}/miunprot/$f))
${MIUNPROT_FILES}:
	ln -s $^ $@
else
${MIUNPROT_FILES}:
	wget -O $@ ${CURRENT_URL}/$@
endif

.PHONY: miunprot
miunprot: ${MIUNPROT_FILES} miunlogo

.PHONY: clean-miunprot
clean-depends distclean: clean-miunprot
clean-miunprot:
	${RM} ${MIUNPROT_FILES}


### MIUN Thesis class ###

miunthes-depend?= 	${TEXMF}/tex/latex/miun/miunthes/miunthes.sty
${miunthes-depend}:
	wget -O /tmp/miunthes.tar.gz \
		http://ver.miun.se/latex/packages/miunthes.tar.gz
	cd /tmp && tar -zxf miunthes.tar.gz
	cd /tmp/miunthes && ${MAKE} install

MIUNTHES_FILES= miunthes.cls miunthes-English.dict miunthes-Swedish.dict

ifdef INCLUDE_MIUNTEX
$(foreach f,${MIUNTHES_FILES},$(eval $f: ${INCLUDE_MIUNTEX}/miunthes/$f))
${MIUNTHES_FILES}:
	ln -s $^ $@
else
${MIUNTHES_FILES}:
	wget -O $@ ${CURRENT_URL}/$@
endif

.PHONY: miunthes
miunthes: ${MIUNTHES_FILES} miunlogo latexmkrc

.PHONY: clean-miunthes
clean-depends distclean: clean-miunthes
clean-miunthes:
	${RM} ${MIUNTHES_FILES}


### INCLUDES ###

INCLUDE_MAKEFILES?= .
INCLUDES= 	depend.mk tex.mk

define inc
ifeq ($(findstring $(1),${MAKEFILE_LIST}),)
$(1):
	wget https://raw.githubusercontent.com/dbosk/makefiles/master/$(1)
include ${INCLUDE_MAKEFILES}/$(1)
endif
endef
$(foreach i,${INCLUDES},$(eval $(call inc,$i)))

### END INCLUDES ###

endif
