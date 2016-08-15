ifndef MIUN_RESULTS_MK
MIUN_RESULTS_MK=true

in?=      new.csv
out?=     reported.csv
report?=  report.pdf
RESULTS_COURSE?=    course identifier
RESULTS_EMAIL?=	    iksexp@miun.se
RESULTS_MAILER?=  mutt -s "resultat ${RESULTS_COURSE}" -a ${report} -- ${RESULTS_EMAIL}
LOCALC?=  localc --norestore
RM?=      /bin/rm -Rf
MV?=      /bin/mv
DIFF?=    diff
JOIN?=    join
CUT?=     cut
SORT?=    sort
HEAD?=    head
TAIL?=    tail
SED?=     sed
GREP?=    grep
CAT?=     cat
CP?=      cp -R
PAGER?=   less
PASTE?=   paste
LN?=      ln
RESULTS_REWRITES+=  "s/Godkänd(G)/G/g" "s/Underkänd(U)/U/g"
RESULTS_REWRITES+=  "s/Komplettering(Fx)/Fx/g"
RESULTS_REWRITES+=  "s/\"//g"
RESULTS_FAILED?=      -\|Fx\?\|U
RESULTS_FAILED_regex= "\( \|	\|,\)\"\?\(${RESULTS_FAILED}\)\"\?\(	.*\)*$$"
RESULTS_COLUMNS?=   4
define store
${RM} $(2) && \
${CUT} -f 1-3,5- $(1) | \
	${SED} "s/ (\([a-z]\{4\}[0-9]\{4\}\))//" | \
	$(if ${RESULTS_REWRITES},${SED} "s/ //g",) \
	$(foreach regex,${RESULTS_REWRITES},| ${SED} ${regex}) > $(2)
endef
.PHONY: report
report:
	if [ ! -s ${out}.new ]; then \
	  echo "No new results to report" >&2; \
	else \
	  ${PAGER} ${report}; \
	  ${RESULTS_MAILER} && \
	  $(call store,${in},${out}); \
	fi
.PHONY: clean clean-results
clean: clean-results
clean-results:
	${RM} ${out}.new
	${RM} ${out}.new ${out}.new.id
	${RM} ${report:.pdf=.csv}
	${RM} ${report}
${out}.new: ${in}
	${GREP} -v "^.\?First \?name" ${in} | \
	${CUT} -f 1-3,5- | \
	${SED} "s/ (\([a-z]\{4\}[0-9]\{4\}\))//" | \
	$(if ${RESULTS_REWRITES},${SED} "s/ //g",) \
	$(foreach regex,${RESULTS_REWRITES},| ${SED} ${regex}) | \
	$(if ${RESULTS_FAILED},${GREP} -v ${RESULTS_FAILED_regex} |,) \
	${DIFF} ${@:.new=} - | ${SED} -n "/^> /s/^> //p" | ${SORT} -k 3 > $@
${out}.new: ${out}
${out}:
	[ -r $@ ] || ${LN} -s /dev/null $@
.SUFFIXES: .csv .csv.new .csv.new.id
.csv.new.csv.new.id:
		@echo "---- userids showed in ${PAGER} ----"
	  ${CAT} $< | ${CUT} -f 3 | ${PAGER}
	  @echo "---- paste username <tab> personnummer, end with C-d on a blank line (EOF) ----"
		${CAT} > $@
.SUFFIXES: .csv .pdf
.csv.pdf:
	${LOCALC} $<
${report:.csv=.pdf}: ${report:.pdf=.csv}
${report:.pdf=.csv}: ${in} ${out}.new ${out}.new.id
	${HEAD} -n 1 ${in} | ${CUT} -f 1-2,5- | ${SED} "s/^/Personnr	/" | \
	  $(if ${RESULTS_REWRITES},${SED} "s/ //g",) \
	  $(foreach regex,${RESULTS_REWRITES},| ${SED} ${regex}) | \
	  ${CUT} -f -${RESULTS_COLUMNS} > $@
	${JOIN} -1 1 -2 3 ${out}.new.id ${out}.new | ${CUT} -d " " -f 2- | \
	  ${SORT} -k 2 | ${CUT} -d " " -f -${RESULTS_COLUMNS} >> $@
.PHONY: report
report: ${report} ${in}

INCLUDE_MAKEFILES?= .
include ${INCLUDE_MAKEFILES}/miun.depend.mk

endif
