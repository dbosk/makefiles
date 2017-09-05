# $Id$
# Author: Daniel Bosk <daniel.bosk@miun.se>

ifndef MIUN_PORT_MK
MIUN_PORT_MK=true

MKFILES=		miun.docs.mk miun.tex.mk miun.subdir.mk
MKFILES+=		miun.package.mk miun.pub.mk miun.course.mk
MKFILES+=		miun.export.mk miun.results.mk miun.depend.mk

miun.export.mk: export.mk
miun.package.mk: pkg.mk
miun.tex.mk: tex.mk
miun.subdir.mk: subdir.mk
miun.results.mk: results.mk

miun.export.mk miun.package.mk miun.tex.mk miun.subdir.mk miun.results.mk:
	ln -s $^ $@

.PHONY: clean-port
clean: clean-port
clean-port:
	${RM} miun.export.mk miun.package.mk miun.tex.mk miun.subdir.mk
	${RM} miun.results.mk

endif
