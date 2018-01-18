ifndef MIUN_EXPORT_MK
MIUN_EXPORT_MK=true

TRANSFORM_SRC=    .tex
TRANSFORM_DST=    .exporttex

TRANSFORM_LIST.exporttex=         NoSolutions
TRANSFORM_LIST-Makefile.export=   OldExportFilter ExportFilter

INCLUDE_MAKEFILES?=.
include ${INCLUDE_MAKEFILES}/transform.mk

endif # MIUN_EXPORT_MK
