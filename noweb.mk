ifndef NOWEB_MK
NOWEB_MK = true

NOWEAVE?=       noweave
NOWEAVEFLAGS?=  -x -n -delay -t2
NOTANGLE?=      notangle
NOTANGLEFLAGS?= -t2
CPIF?=          cpif
NOWEB_SUFFIXES+=    .c .cc .cpp .cxx
NOTANGLEFLAGS.c?=   ${NOTANGLEFLAGS} -L
NOTANGLE.c?=        ${NOTANGLE} ${NOTANGLEFLAGS.c} -R$@ $< | ${CPIF} $@
NOTANGLEFLAGS.cc?=  ${NOTANGLEFLAGS.c}
NOTANGLE.cc?=       ${NOTANGLE} ${NOTANGLEFLAGS.cc} -R$@ $< | ${CPIF} $@
NOTANGLEFLAGS.cpp?= ${NOTANGLEFLAGS.c}
NOTANGLE.cpp?=      ${NOTANGLE} ${NOTANGLEFLAGS.cpp} -R$@ $< | ${CPIF} $@
NOTANGLEFLAGS.cxx?= ${NOTANGLEFLAGS.c}
NOTANGLE.cxx?=      ${NOTANGLE} ${NOTANGLEFLAGS.cxx} -R$@ $< | ${CPIF} $@
NOWEB_SUFFIXES+=    .h .hh .hpp .hxx
NOTANGLEFLAGS.h?=   ${NOTANGLEFLAGS} -L
NOTANGLE.h?=        ${NOTANGLE} ${NOTANGLEFLAGS.h} -R$@ $< | ${CPIF} $@
NOTANGLEFLAGS.hh?=  ${NOTANGLEFLAGS.h}
NOTANGLE.hh?=       ${NOTANGLE} ${NOTANGLEFLAGS.hh} -R$@ $< | ${CPIF} $@
NOTANGLEFLAGS.hpp?= ${NOTANGLEFLAGS.h}
NOTANGLE.hpp?=      ${NOTANGLE} ${NOTANGLEFLAGS.hpp} -R$@ $< | ${CPIF} $@
NOTANGLEFLAGS.hxx?= ${NOTANGLEFLAGS.h}
NOTANGLE.hxx?=      ${NOTANGLE} ${NOTANGLEFLAGS.hxx} -R$@ $< | ${CPIF} $@
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
define with_suffix_target
%$(1): %$(1).nw
	$${NOTANGLE$$(suffix $$@)}
endef
$(foreach suf,${NOWEB_SUFFIXES},$(eval $(call with_suffix_target,${suf})))
$(addprefix %,${NOWEB_SUFFIXES}): %.nw
	${NOTANGLE$(suffix $@)}
%.h: %.c.nw
	${NOTANGLE.h}

%.hh: %.cc.nw
	${NOTANGLE.hh}

%.hpp: %.cpp.nw
	${NOTANGLE.hpp}

%.hxx: %.cxx.nw
	${NOTANGLE.hxx}

endif
