# $Id$
# Author:	Daniel Bosk <daniel.bosk@miun.se>

ifndef MIUN_RESULTS_MK
MIUN_RESULTS_MK=true

in?=		${COURSE}.txt
out?=		reported.csv
report?=	new.csv

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
report: ${report} ${out}
	if [ ! -s ${out}.new ]; then \
		echo "No new results to report" >&2; \
	else \
		${PAGER} ${report}; \
		${MAILER}; \
	fi

# create a csv for long storage of results
${out}: ${in}
	${RM} $@
	${CUT} -f 1-3,5- $^ | \
		${SED} "s/ (\([a-z]\{4\}[0-9]\{4\}\))//" | \
		$(if ${REWRITES},${SED} "s/ //g",) \
		$(foreach regex,${REWRITES},| ${SED} ${regex}) > $@

.PHONY: clean clean-results
# remove intermediate helper files
clean: clean-results
clean-results:
	${RM} ${out}.out ${out}.pnr ${out}.head ${out}.new ${out}.rewrite \
		#$(shell echo ${in} | ${SED} "s/^\(.*\)\.\([^.]\{1,\}\)$$/\1.csv/") \
	${RM} ${report} \
		$(shell echo ${report} | ${SED} "s/^\(.*\)\.\([^.]\{1,\}\)$$/\1.csv/")
	${RM} ${out}.new.out ${out}.new.pnr ${out}.new.new ${out}.new.rewrite;
	${RM} ${out}.tmp

# sort out the new results by comparing previously reported and new results
${out}.new: ${in}
	[ -r ${out} ] || ln -s /dev/null ${out}
	${GREP} -v "^.\?First \?name" $^ | \
		${CUT} -f 1-3,5- | \
		${SED} "s/ (\([a-z]\{4\}[0-9]\{4\}\))//" | \
		$(if ${REWRITES},${SED} "s/ //g",) \
		$(foreach regex,${REWRITES},| ${SED} ${regex}) | \
		$(if ${FAILED},${GREP} -v ${FAILED_regex} |,) \
		${DIFF} ${out} - | ${SED} -n "/^> /s/^> //p" | ${SORT} -k 3 > $@

.SUFFIXES: .csv .pdf
.csv.pdf: localc
	${LOCALC} $<

.SUFFIXES: .csv.new
.csv.new.csv:
	${CP} $< $@

.csv.new.pdf: localc
	${LOCALC} $<

${report}: ${in} ${out}.new ${out}.new.pnr
	${HEAD} -n 1 ${in} | ${CUT} -f 1-2,5- | ${SED} "s/^/Personnr	/" | \
		$(if ${REWRITES},${SED} "s/ //g",) \
		$(foreach regex,${REWRITES},| ${SED} ${regex}) > $@
	${JOIN} -1 1 -2 3 ${out}.new.pnr ${out}.new | ${CUT} -f 2- | \
		${SORT} -k 3 >> $@

.SUFFIXES: .csv.new.pnr
# filter out the userid from csv file
.csv.new.csv.new.pnr:
	${CAT} $< | ${CUT} -f 3 | ${SORT} -k 1 > $@.tmp
	${PAGER} $@.tmp
	@echo "---- paste personnummer, end with C-d on a blank line (EOF) ----"
	${CAT} | ${PASTE} $@.tmp - > $@
	${RM} $@.tmp

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
