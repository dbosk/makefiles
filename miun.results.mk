# $Id$
# Author:	Daniel Bosk <daniel.bosk@miun.se>

ifndef MIUN_RESULTS_MK
MIUN_RESULTS_MK=true

in?=		${COURSE}.txt
out?=		reported.csv
report?=	new_results.pdf

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

.SUFFIXES: .csv .txt .pnr
.PHONY: clean report

# convert old moodle .txt format to new moodle .csv format
.txt.csv:
	${CAT} $< | \
		${SED} "s/ (\([a-z]\{4\}[0-9]\{4\}\))/	\1/" | \
		${SED} "s/Surname/Surname	Username/" > $@

# filter out the userid from csv file
.csv.pnr: localc
	${CUT} -f 6 > $@
	${LOCALC} $@

# phony target used to send results
report: ${report} ${out}
	${MAILER}

# create a csv for long storage of results
${out}: $(shell echo ${in} | ${SED} "s/^\(.*\)\.\([^.]\{1,\}\)$$/\1.csv/")
	${CP} $(shell echo ${in} | ${SED} "s/^\(.*\)\.\([^.]\{1,\}\)$$/\1.csv/") \
		$@.tmp
	${RM} $@
	${CUT} -f 1-3,5- $@.tmp | \
		${SED} "s/ (\([a-z]\{4\}[0-9]\{4\}\))//" | \
		$(if ${REWRITES},${SED} "s/ //g",) \
		$(foreach regex,${REWRITES},| ${SED} ${regex}) > $@
	#${RM} $@.tmp

# remove intermediate helper files
clean-results:
	${RM} ${out}.out ${out}.pnr ${out}.head ${out}.new ${out}.rewrite \
		#$(shell echo ${in} | ${SED} "s/^\(.*\)\.\([^.]\{1,\}\)$$/\1.csv/") \
	${RM} ${report} \
		$(shell echo ${report} | ${SED} "s/^\(.*\)\.\([^.]\{1,\}\)$$/\1.csv/")
	${RM} ${out}.new.out ${out}.new.pnr ${out}.new.new ${out}.new.rewrite;
	${RM} ${out}.tmp

clean: clean-results

# sort out the new results by comparing previously reported and new results
${out}.new: $(shell echo ${in} | ${SED} "s/^\(.*\)\.\([^.]\{1,\}\)$$/\1.csv/") \
	localc
	[ -r ${out} ] || ln -s /dev/null ${out}
	${GREP} -v "^.\?First \?name" $^ | \
		${CUT} -f 1-3,5- | \
		${SED} "s/ (\([a-z]\{4\}[0-9]\{4\}\))//" | \
		$(if ${REWRITES},${SED} "s/ //g",) \
		$(foreach regex,${REWRITES},| ${SED} ${regex}) | \
		$(if ${FAILED},${GREP} -v ${FAILED_regex} |,) \
		${DIFF} ${out} - | ${SED} -n "/^> /s/^> //p" | ${SORT} -k 3 > $@.new
	if [ ! -s $@.new ]; then \
		${RM} $@.out $@.pnr $@.new $@.rewrite; \
		${MAKE} in=${in} out=${out} report=${report} clean; \
		echo "No new results to report" >&2; \
		false; \
	fi
	${CAT} $@.new
	${CAT} $@.new | ${CUT} -f 3 | ${SORT} -k 1 > $@.pnr
	${LOCALC} $@.pnr
	${JOIN} -1 1 -2 3 $@.pnr $@.new | ${CUT} -f 2- > $@.out
	${CAT} $@.out
	${HEAD} -n 1 $^ | ${CUT} -f 1-2,5- | ${SED} "s/^/Personnr	/" | \
		$(if ${REWRITES},${SED} "s/ //g",) \
		$(foreach regex,${REWRITES},| ${SED} ${regex})  > $@
	${CAT} $@.out | ${SORT} -k 3 >> $@
	#${RM} $@.out $@.pnr $@.new $@.rewrite

# generate the PDF with new results to be sent to ${EXPADDR}
${report}: ${out}.new localc
	NEWFILE="$(shell echo $@ | ${SED} "s/^\(.*\)\.\([^.]\{1,\}\)$$/\1.csv/")"; \
			${CP} $^ $${NEWFILE}; \
			${LOCALC} $${NEWFILE} && ${RM} $${NEWFILE}


### INCLUDES ###

INCLUDES= 	miun.depend.mk

define inc
ifeq ($(findstring $(1),${MAKEFILE_LIST}),)
$(1):
	wget https://raw.githubusercontent.com/dbosk/makefiles/master/$@
include $(1)
endif
endef
$(foreach i,${INCLUDES},$(call inc,$i))

### END INCLUDES ###

endif
