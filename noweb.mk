ifndef NOWEB_MK
NOWEB_MK = true

NOWEAVE?=       noweave ${NOWEAVEFLAGS} $< > $@
NOWEAVEFLAGS?=  -x -n -delay -t2
NOTANGLE?=      notangle ${NOTANGLEFLAGS} -R$(notdir $@) $< | ${CPIF} $@
NOTANGLEFLAGS?=
CPIF?=          cpif
NOWEB_SUFFIXES+=    .c .cc .cpp .cxx
NOTANGLEFLAGS.c?=   ${NOTANGLEFLAGS} -L
NOTANGLE.c?=        notangle ${NOTANGLEFLAGS.c} -R$(notdir $@) $< | ${CPIF} $@
NOTANGLEFLAGS.cc?=  ${NOTANGLEFLAGS.c}
NOTANGLE.cc?=       notangle ${NOTANGLEFLAGS.cc} -R$(notdir $@) $< | ${CPIF} $@
NOTANGLEFLAGS.cpp?= ${NOTANGLEFLAGS.c}
NOTANGLE.cpp?=      notangle ${NOTANGLEFLAGS.cpp} -R$(notdir $@) $< | ${CPIF} $@
NOTANGLEFLAGS.cxx?= ${NOTANGLEFLAGS.c}
NOTANGLE.cxx?=      notangle ${NOTANGLEFLAGS.cxx} -R$(notdir $@) $< | ${CPIF} $@
NOWEB_SUFFIXES+=    .h .hh .hpp .hxx
NOTANGLEFLAGS.h?=   ${NOTANGLEFLAGS} -L
NOTANGLE.h?=        notangle ${NOTANGLEFLAGS.h} -R$(notdir $@) $< | ${CPIF} $@
NOTANGLEFLAGS.hh?=  ${NOTANGLEFLAGS.h}
NOTANGLE.hh?=       notangle ${NOTANGLEFLAGS.hh} -R$(notdir $@) $< | ${CPIF} $@
NOTANGLEFLAGS.hpp?= ${NOTANGLEFLAGS.h}
NOTANGLE.hpp?=      notangle ${NOTANGLEFLAGS.hpp} -R$(notdir $@) $< | ${CPIF} $@
NOTANGLEFLAGS.hxx?= ${NOTANGLEFLAGS.h}
NOTANGLE.hxx?=      notangle ${NOTANGLEFLAGS.hxx} -R$(notdir $@) $< | ${CPIF} $@
NOWEB_SUFFIXES+=    .hs
NOTANGLEFLAGS.hs?=  ${NOTANGLEFLAGS} -L
NOTANGLE.hs?=       notangle ${NOTANGLEFLAGS.hs} -R$(notdir $@) $< | ${CPIF} $@
NOWEB_SUFFIXES+=    .py
NOTANGLEFLAGS.py?=  ${NOTANGLEFLAGS}
NOTANGLE.py?=       notangle ${NOTANGLEFLAGS.py} -R$(notdir $@) $< > $@
NOWEB_SUFFIXES+=    .mk
NOTANGLEFLAGS.mk?=  ${NOTANGLEFLAGS} -t2
NOTANGLE.mk?=       notangle ${NOTANGLEFLAGS.mk} -R$(notdir $@) $< > $@
NOWEB_SUFFIXES+=    .sty .cls
NOTANGLEFLAGS.sty?= ${NOTANGLEFLAGS}
NOTANGLE.sty?=      notangle ${NOTANGLEFLAGS.sty} -R$(notdir $@) $< > $@
NOTANGLEFLAGS.cls?= ${NOTANGLEFLAGS}
NOTANGLE.cls?=      notangle ${NOTANGLEFLAGS.cls} -R$(notdir $@) $< > $@
NOWEB_SUFFIXES+=    .sh
NOTANGLEFLAGS.sh?=  ${NOTANGLEFLAGS}
NOTANGLE.sh?=       notangle ${NOTANGLEFLAGS.sh} -R$(notdir $@) $< > $@
.SUFFIXES: .nw .tex $(addsuffix .nw,${NOWEB_SUFFIXES})
.nw.tex $(addsuffix .nw.tex,${NOWEB_SUFFIXES}):
	${NOWEAVE}
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
