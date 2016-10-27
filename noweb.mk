ifndef NOWEB_MK
NOWEB_MK = true

NOWEB_WEAVE_FLAGS?= -x -n -delay -t2
NOWEB_TANGLE_FLAGS?= -t2
.SUFFIXES: .nw .tex .py.nw .c.nw .h.nw .cpp.nw .hpp.nw .mk.nw
.nw.tex .py.nw.tex .c.nw.tex .h.nw.tex .cpp.nw.tex .hpp.nw.tex .mk.nw.tex:
	noweave ${NOWEB_WEAVE_FLAGS} $< > $@
.SUFFIXES: .nw .c.nw .cpp.nw .cxx.nw .c .cpp .cxx
.nw.c .c.nw.c .nw.cpp .cpp.nw.cpp .nw.cxx .cxx.nw.cxx:
	notangle ${NOWEB_TANGLE_FLAGS} -L -R$@ $< | cpif $@

.SUFFIXES: .h .hpp .hxx
.nw.h .c.nw.h .nw.hpp .cpp.nw.hpp .nw.hxx .cxx.nw.hxx:
	notangle ${NOWEB_TANGLE_FLAGS} -L -R$@ $< | cpif $@
.SUFFIXES: .hs.nw .hs
.nw.hs .hs.nw.hs:
	notangle ${NOWEB_TANGLE_FLAGS} -L -R$@ $< | cpif $@
.SUFFIXES: .nw .py.nw .py
.nw.py .py.nw.py:
	notangle ${NOWEB_TANGLE_FLAGS} -R$@ $< | cpif $@
# implicit rules for make(1) includes
.SUFFIXES: .nw .mk.nw .mk
.nw.mk .mk.nw.mk:
	notangle ${NOWEB_TANGLE_FLAGS} -R$@ $< | cpif $@

endif
