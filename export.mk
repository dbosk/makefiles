ifndef EXPORT_MK
EXPORT_MK=true

ifeq (${MAKE},gmake)
SED?=     gsed
else
SED?=     sed
endif
EXPORT_SRC?=    .tex
EXPORT_DST?=    .transformed.tex
GPG?=                 gpg
EXPORT_ENC?=          ${GPG} -aes
EXPORT_RECIPIENTS?=   me
EXPORT_DEC?=          ${GPG} -d
define transform
cat $(1) $(foreach t,$(2),| $(call ${t})) > $(3)
endef
NoSolutions?= ${SED} "/\\\\begin{solution}/,/\\\\end{solution}/d"
ExportFilter?=  ${SED} "/#export false/,/#export true/d"
.SUFFIXES: ${EXPORT_SRC} ${EXPORT_DST}
$(foreach src,${EXPORT_SRC},$(foreach dst,${EXPORT_DST},${src}${dst})):
	$(call transform,$^,${EXPORT_TRANSFORM-$@},$@)
define target_recipe
$(1):
	$(call transform,$^,${EXPORT_TRANSFORM-$@},$@)
endef
$(foreach target,${EXPORT_TARGETS},$(eval $(call target_recipe,${target})))

.SUFFIXES: .tex .tex.asc
.tex.tex.asc:
	${EXPORT_ENC} $(foreach r,${EXPORT_RECIPIENTS}, -r $r) < $< > $@

.tex.asc.tex:
	${EXPORT_DEC} < $< > $@

endif
