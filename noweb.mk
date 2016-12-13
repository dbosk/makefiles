ifndef NOWEB_MK
NOWEB_MK = true

NOWEAVE?=       noweave
NOWEAVEFLAGS?=  -x -n -delay -t2
NOTANGLE?=      notangle
NOTANGLEFLAGS?= -t2
CPIF?=          cpif

NOWEB_SUFFIXES+=    .hs
NOTANGLEFLAGS.hs?=  ${NOTANGLEFLAGS} -L
NOTANGLE.hs?=       ${NOTANGLE} ${NOTANGLEFLAGS.hs} -R$@ $< | ${CPIF} $@
NOWEB_SUFFIXES+=    .py
NOTANGLEFLAGS.py?=  ${NOTANGLEFLAGS}
NOTANGLE.py?=       ${NOTANGLE} ${NOTANGLEFLAGS.py} -R$@ $< > $@
NOWEB_SUFFIXES+=    .mk
NOTANGLEFLAGS.mk?=  ${NOTANGLEFLAGS}
NOTANGLE.mk?=       ${NOTANGLE} ${NOTANGLEFLAGS.mk} -R$@ $< > $@
.SUFFIXES: .nw .tex $(addsuffix .nw,${NOWEB_SUFFIXES})
.nw.tex $(addsuffix .nw.tex,${NOWEB_SUFFIXES}):
	${NOWEAVE} ${NOWEAVEFLAGS} $< > $@
%: %.nw
	${NOTANGLE$(suffix $@)}
$(addprefix %,${NOWEB_SUFFIXES}): %.nw
	${NOTANGLE$(suffix $@)}


endif
