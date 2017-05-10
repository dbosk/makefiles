EXAM_NAME?=   exam
EXAM_QNAME?=  questions
EXAM_IDS?=    $(shell date +%y%m%d)
EXAM_TAGS?=     ILO1 ILO2 ... ILOn
EXAM_DBS?=      $(foreach id,${EXAM_IDS},${EXAM_QNAME}-${id}.tex)
EXAM_FLAGS?=        -NCE
define target_variables
EXAM_NAME-$(1)?=   ${EXAM_NAME}
EXAM_QNAME-$(1)?=  ${EXAM_QNAME}
endef
$(foreach id,${EXAM_IDS},$(eval $(call target_variables,${id})))
define exam_target
${EXAM_NAME-$(1)}-$(1).pdf: ${EXAM_NAME-$(1)}-$(1).tex
${EXAM_NAME-$(1)}-$(1).pdf: ${EXAM_QNAME-$(1)}-$(1).tex
endef
$(foreach id,${EXAM_IDS},$(eval $(call exam_target,${id})))
define questions_variables
EXAM_TAGS-$(1)?=    ${EXAM_TAGS}
EXAM_DBS-$(1)?=     ${EXAM_DBS}
EXAM_FLAGS-$(1)?=   ${EXAM_FLAGS}
endef
$(foreach id,${EXAM_IDS},$(eval $(call questions_variables,${id})))
define questions_target
.INTERMEDIATE: ${EXAM_QNAME-$(1)}-$(1).tex
${EXAM_QNAME-$(1)}-$(1).tex: ${EXAM_DBS-$(1)}
	examgen ${EXAM_FLAGS-$(1)} -d ${EXAM_DBS-$(1)} -t ${EXAM_TAGS-$(1)} > $$@
endef
$(foreach id,${EXAM_IDS},$(eval $(call questions_target,${id})))
