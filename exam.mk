EXAM_NAME?=     exam
EXAM_TEMPLATE?= template
EXAM_QNAME?=    questions
EXAM_IDS?=    $(shell date +%y%m%d)
EXAM_TAGS?=     ILO1 ILO2 ... ILOn
EXAM_DBS?=      $(foreach id,${EXAM_IDS},${EXAM_QNAME}-${id}.tex)
EXAM_FLAGS?=        -NCE
define exam_tex_files
${EXAM_NAME}-$(1).tex:
	${CAT} ${EXAM_NAME}-${EXAM_TEMPLATE}.tex | \
	  ${SED} \
		  -e "s/<EXAM_DATE>/${EXAM_DATE-$(1)}/g" \
		  -e "s/<EXAM_ID>/$(1)/g" \
		  -e "s/<EXAM_QNAME>/${EXAM_QNAME}/g" \
	  > $$@
endef
$(foreach id,${EXAM_IDS},$(eval $(call exam_tex_files,${id})))
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
.PRECIOUS: ${EXAM_QNAME-$(1)}-$(1).tex
${EXAM_QNAME-$(1)}-$(1).tex:
	examgen ${EXAM_FLAGS-$(1)} -d ${EXAM_DBS-$(1)} -t ${EXAM_TAGS-$(1)} > $$@
endef
$(foreach id,${EXAM_IDS},$(eval $(call questions_target,${id})))
