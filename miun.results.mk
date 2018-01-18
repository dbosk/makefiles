ifndef MIUN_RESULTS_MK
MIUN_RESULTS_MK=true

in?=              ${COURSE}.txt
out?=              reported.csv
report?=          new_results.pdf

RESULTS_COURSE?=  ${COURSE}
RESULTS_EMAIL?=   ${EXPADDR}

MAILER?=	thunderbird -compose \
  "to=${EXPADDR},subject='resultat ${COURSE}',attachment='file://${report}'"
RESULTS_MAILER?=  ${MAILER}

REWRITES?=	"s/Godkänd(G)/G/g" "s/Underkänd(U)/U/g" "s/Komplettering(Fx)/Fx/g"
RESULTS_REWRITES?=${REWRITES}

FAILED?=	-\|Fx\?\|U
RESULTS_FAILED?=  ${FAILED}

FAILED_regex=	"	\(${FAILED}\)\(	.*\)*$$"
RESULTS_FAILED_regex?=${FAILED_regex}

INCLUDE_MAKEFILES?=.
include ${INCLUDE_MAKEFILES}/results.mk

endif # MIUN_RESULTS_MK
