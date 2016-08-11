.SUFFIXES: .nw

# implicit rules for C and C++ code
.SUFFIXES: .c.nw .cpp.nw .cxx.nw
.SUFFIXES: .c .cpp .cxx
.nw.c .c.nw.c .nw.cpp .cpp.nw.cpp .nw.cxx .cxx.nw.cxx: noweb
	notangle -R$@ -L $< | cpif $@

# implicit rules for C and C++ headers
.SUFFIXES: .h .hpp .hxx
.nw.h .c.nw.h .nw.hpp .cpp.nw.hpp .nw.hxx .cxx.nw.hxx: noweb
	notangle -R$@ $< | cpif $@

# implicit rules for Python
.SUFFIXES: .py.nw
.SUFFIXES: .py
.nw.py .py.nw.py: noweb
	notangle -R$@ $< | cpif $@

# implicit rules for make(1) includes
.SUFFIXES: .mk.nw
.SUFFIXES: .mk
.nw.mk .mk.nw.mk: noweb
	notangle -t2 -R$@ $< | cpif $@


INCLUDE_MAKEFILES?=.
include ${INCLUDE_MAKEFILES}/depend.mk
