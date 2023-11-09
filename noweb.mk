ifndef NOWEB_MK
NOWEB_MK = true

NOWEAVE.tex?=       noweave ${NOWEAVEFLAGS.tex} $< > $@
NOWEAVEFLAGS.tex?=  ${NOWEAVEFLAGS} -x -n -delay -t2
NOWEAVE.pdf?=       \
  noweave ${NOWEAVEFLAGS.pdf} $< > ${@:.pdf=.tex} && \
  latexmk -pdf ${@:.pdf=.tex}
NOWEAVEFLAGS.pdf?=  ${NOWEAVEFLAGS} -x -t2
NOTANGLEFLAGS?=
NOTANGLE?=      notangle ${NOTANGLEFLAGS} -R$(notdir $@) $(filter %.nw,$^) | \
                  ${CPIF} $@ && noroots $(filter %.nw,$^)
CPIF?=          cpif
NOWEB_SUFFIXES+=    .c .cc .cpp .cxx
NOTANGLEFLAGS.c?=   -L
NOTANGLE.c?=        notangle ${NOTANGLEFLAGS.c} -R$(notdir $@) \
  $(filter %.nw,$^) | ${CPIF} $@ && noroots $(filter %.nw,$^)
NOTANGLEFLAGS.cc?=  ${NOTANGLEFLAGS.c}
NOTANGLE.cc?=       notangle ${NOTANGLEFLAGS.cc} -R$(notdir $@) \
  $(filter %.nw,$^) | ${CPIF} $@ && noroots $(filter %.nw,$^)
NOTANGLEFLAGS.cpp?= ${NOTANGLEFLAGS.c}
NOTANGLE.cpp?=      notangle ${NOTANGLEFLAGS.cpp} -R$(notdir $@) \
  $(filter %.nw,$^) | ${CPIF} $@ && noroots $(filter %.nw,$^)
NOTANGLEFLAGS.cxx?= ${NOTANGLEFLAGS.c}
NOTANGLE.cxx?=      notangle ${NOTANGLEFLAGS.cxx} -R$(notdir $@) \
  $(filter %.nw,$^) | ${CPIF} $@ && noroots $(filter %.nw,$^)
NOWEB_SUFFIXES+=    .h .hh .hpp .hxx
NOTANGLEFLAGS.h?=   -L
NOTANGLE.h?=        notangle ${NOTANGLEFLAGS.h} -R$(notdir $@) \
  $(filter %.nw,$^) | ${CPIF} $@ && noroots $(filter %.nw,$^)
NOTANGLEFLAGS.hh?=  ${NOTANGLEFLAGS.h}
NOTANGLE.hh?=       notangle ${NOTANGLEFLAGS.hh} -R$(notdir $@) \
  $(filter %.nw,$^) | ${CPIF} $@ && noroots $(filter %.nw,$^)
NOTANGLEFLAGS.hpp?= ${NOTANGLEFLAGS.h}
NOTANGLE.hpp?=      notangle ${NOTANGLEFLAGS.hpp} -R$(notdir $@) \
  $(filter %.nw,$^) | ${CPIF} $@ && noroots $(filter %.nw,$^)
NOTANGLEFLAGS.hxx?= ${NOTANGLEFLAGS.h}
NOTANGLE.hxx?=      notangle ${NOTANGLEFLAGS.hxx} -R$(notdir $@) \
  $(filter %.nw,$^) | ${CPIF} $@ && noroots $(filter %.nw,$^)
NOWEB_SUFFIXES+=    .hs
NOTANGLEFLAGS.hs?=  -L
NOTANGLE.hs?=       notangle ${NOTANGLEFLAGS.hs} -R$(notdir $@) \
  $(filter %.nw,$^) | ${CPIF} $@ && noroots $(filter %.nw,$^)
NOWEB_SUFFIXES+=    .mk
NOTANGLEFLAGS.mk?=  -t2
NOTANGLE.mk?=       notangle ${NOTANGLEFLAGS.mk} -R$(notdir $@) \
  $(filter %.nw,$^) > $@ && noroots $(filter %.nw,$^)
NOWEB_SUFFIXES+=    .py .sty .cls .sh .go

define default_tangling
NOTANGLEFLAGS$(1)?=
NOTANGLE$(1)?=      notangle $${NOTANGLEFLAGS$(1)} -R$$(notdir $$@) \
  $$(filter %.nw,$$^) > $$@ && noroots $$(filter %.nw,$$^)
endef

$(foreach suffix,${NOWEB_SUFFIXES},$(eval $(call default_tangling,${suffix})))
NOTANGLE.py+=       && ${NOWEB_PYCODEFMT}
NOWEB_PYCODEFMT?=   black $@

INCLUDE_MAKEFILES?=.
MAKEFILES_DIR?=${INCLUDE_MAKEFILES}
include ${MAKEFILES_DIR}/tex.mk

%.pdf: %.nw
	${NOWEAVE.pdf}

define def_weave_to_pdf
%.pdf: %$(1).nw
	$${NOWEAVE.pdf}
endef

$(foreach suf,${NOWEB_SUFFIXES},$(eval $(call def_weave_to_pdf,${suf})))
%.tex: %.nw
	${NOWEAVE.tex}

define def_weave_to_tex
%.tex: %$(1).nw
	$${NOWEAVE.tex}
endef

$(foreach suf,${NOWEB_SUFFIXES},$(eval $(call def_weave_to_tex,${suf})))
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
