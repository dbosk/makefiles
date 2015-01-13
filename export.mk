# $Id$
# Author:	Daniel Bosk <daniel.bosk@miun.se>
# Date:		29 Dec 2012

ifndef EXPORT_MK
EXPORT_MK=true

.SUFFIXES: .tex .exporttex
.tex.exporttex: sed
	${SED} "/\\\\begin{solution}/,/\\\\end{solution}/d" $< > $@

.SUFFIXES: .export.tex
.tex.export.tex: sed
	${SED} "/\\\\begin{solution}/,/\\\\end{solution}/d" $< > $@

Makefile.export: sed
	${SED} "/#export no/,/#endexport/d" $< > $@

.PHONY: clean clean-export	
clean: clean-export
clean-export:
	${RM} Makefile.export *.exporttex *.export.tex


### INCLUDES ###

INCLUDES= 	depend.mk

define inc
ifeq ($(findstring $(1),${MAKEFILE_LIST}),)
$(1):
	wget https://raw.githubusercontent.com/dbosk/makefiles/master/$(1)
include $(1)
endif
endef
$(foreach i,${INCLUDES},$(eval $(call inc,$i)))

endif
