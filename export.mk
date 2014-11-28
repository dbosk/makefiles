# $Id$
# Author:	Daniel Bosk <daniel.bosk@miun.se>
# Date:		29 Dec 2012

ifndef EXPORT_MK
EXPORT_MK=true

.SUFFIXES: .tex .exporttex
.tex.exporttex:
	sed "/\\\\begin{solution}/,/\\\\end{solution}/d" $< > $@

.SUFFIXES: .export.tex
.tex.export.tex:
	sed "/\\\\begin{solution}/,/\\\\end{solution}/d" $< > $@

Makefile.export:
	sed "/#export no/,/#endexport/d" $< > $@

.PHONY: clean clean-export	
clean: clean-export
clean-export:
	${RM} Makefile.export *.exporttex *.export.tex

endif
