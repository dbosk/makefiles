# $Id$
# Author:	Daniel Bosk <daniel.bosk@miun.se>

ifndef MIUN_RESULTS_MK
MIUN_RESULTS_MK=true

in?=		${COURSE}.txt
out?=		reported.csv
report?=	report.pdf

COURSE?=
EXPADDR?=	iksexp@miun.se
#MAILER?=	mutt -s "resultat ${COURSE}" -a ${report} -- ${EXPADDR}
MAILER?=	thunderbird -compose "to=${EXPADDR},subject='resultat ${COURSE}',attachment='file://${report}'"
REWRITES?=	"s/Godkänd(G)/G/g" "s/Underkänd(U)/U/g" "s/Komplettering(Fx)/Fx/g"
FAILED?=	-\|Fx\?\|U
FAILED_regex=	"	\(${FAILED}\)\(	.*\)*$$"

LOCALC?=	localc --norestore
RM?=		/bin/rm -Rf
MV?=		/bin/mv
DIFF?=		diff
JOIN?=		join -t "	"
CUT?=		cut
SORT?=		sort -t "	"
HEAD?=		head
TAIL?=		tail
SED?=		sed
GREP?=		grep
CAT?=		cat
CP?=		cp -R
PAGER?= 	less
PASTE?= 	paste

.PHONY: report
# phony target used to send results
report: ${report} ${in}
	if [ ! -s ${out}.new ]; then \
		echo "No new results to report" >&2; \
	else \
		${PAGER} ${report}; \
		${MAILER} && \
		$(call store,${in},${out}); \
	fi

# create a csv for long storage of results
define store
${RM} $(2) && \
${CUT} -f 1-3,5- $(1) | \
	${SED} "s/ (\([a-z]\{4\}[0-9]\{4\}\))//" | \
	$(if ${REWRITES},${SED} "s/ //g",) \
	$(foreach regex,${REWRITES},| ${SED} ${regex}) > $(2)
endef

.PHONY: clean clean-results
# remove intermediate helper files
clean: clean-results
clean-results:
	${RM} ${report} ${report:.pdf=.csv} ${out}.new ${out}.new.pnr

.SUFFIXES: .csv .pdf
# convert a csv to pdf
.csv.pdf: localc
	#${LOCALC} --convert-to pdf $< --headless
	${LOCALC} $<

.SUFFIXES: .csv .csv.new
# turn new results into a new csv
.csv.new.csv:
	${CP} $< $@

.SUFFIXES: .pdf .csv.new
# turn new results into a pdf
.csv.new.pdf: localc
	${LOCALC} --convert-to pdf $<

${out}:
	[ -r $@ ] || ln -s /dev/null $@

${out}.new: ${in} ${out}
	${GREP} -v "^.\?First \?name" ${in} | \
		${CUT} -f 1-3,5- | \
		${SED} "s/ (\([a-z]\{4\}[0-9]\{4\}\))//" | \
		$(if ${REWRITES},${SED} "s/ //g",) \
		$(foreach regex,${REWRITES},| ${SED} ${regex}) | \
		$(if ${FAILED},${GREP} -v ${FAILED_regex} |,) \
		${DIFF} ${@:.new=} - | ${SED} -n "/^> /s/^> //p" | ${SORT} -k 3 > $@

.SUFFIXES: .csv.new.pnr
# filter out the userid from csv file, accept a paste of userid\t personnummer
.csv.new.csv.new.pnr:
	@echo "---- userids showed in ${PAGER} ----"
	${CAT} $< | ${CUT} -f 3 | ${SORT} -k 1 | ${PAGER}
	@echo "---- paste personnummer, end with C-d on a blank line (EOF) ----"
	${CAT} > $@

# create the report, join personnummer and results
${report:.csv=.pdf}: ${report:.pdf=.csv}

${report:.pdf=.csv}: ${in} ${out}.new ${out}.new.pnr
	${HEAD} -n 1 ${in} | ${CUT} -f 1-2,5- | ${SED} "s/^/Personnr	/" | \
		$(if ${REWRITES},${SED} "s/ //g",) \
		$(foreach regex,${REWRITES},| ${SED} ${regex}) > $@
	${JOIN} -1 1 -2 3 ${out}.new.pnr ${out}.new | ${CUT} -f 2- | \
		${SORT} -k 3 >> $@

### INCLUDES ###

INCLUDES= 	miun.depend.mk

define inc
ifeq ($(findstring $(1),${MAKEFILE_LIST}),)
$(1):
	wget https://raw.githubusercontent.com/dbosk/makefiles/master/$(1)
include $(1)
endif
endef
$(foreach i,${INCLUDES},$(eval $(call inc,$i)))

### END INCLUDES ###

endif
