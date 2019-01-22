ifndef PUB_MK
PUB_MK=true

INCLUDE_MAKEFILES?=.
include ${INCLUDE_MAKEFILES}/portability.mk

PUB_FILES?=
IGNORE_FILES?=      \(\.svn\|\.git\|CVS\)
PUB_IGNORE?=        ${IGNORE_FILES}
PUB_SERVER?=        localhost
PUB_DIR?=           ${PUBDIR}/${CATEGORY}
PUB_USER?=          ${USER}
PUB_GROUP?=         ${GROUP}
PUB_CHMOD?=         o+r
PUB_METHOD?=        ssh
at?=                tomorrow
PKG_AT?=            ${at}
PUB_TMPDIR?=        /var/tmp
PUB_BRANCH?=        master
PUB_SITES?=         main
define variables
PUB_METHOD-$(1)?=   ${PUB_METHOD}

PUB_SERVER-$(1)?=   ${PUB_SERVER}
PUB_DIR-$(1)?=      ${PUB_DIR}
PUB_FILES-$(1)?=    ${PUB_FILES}
PUB_IGNORE-$(1)?=   ${PUB_IGNORE}

PUB_USER-$(1)?=     ${PUB_USER}
PUB_GROUP-$(1)?=    ${PUB_GROUP}
PUB_CHMOD-$(1)?=    ${PUB_CHMOD}

PUB_AT-$(1)?=       ${PUB_AT}
PUB_TMPDIR-$(1)?=   ${PUB_TMPDIR}

PUB_BRANCH-$(1)?=   ${PUB_BRANCH}
endef

$(foreach site,${PUB_SITES},$(eval $(call variables,${site})))
PUB_AUTOTAG?=       false
PUB_VCS?=           git
PUB_TAG_OPTS?=
PUB_TAG_NAME?=      $(shell date +%Y%m%d-%H%M)
PUB_AUTOCOMMIT?=    false
PUB_COMMIT_OPTS?=   -av
PUB_REGEX?=     "|^(.*)$$$$|\1|p"
$(foreach site,${PKG_SITES},$(eval PUB_REGEX-${site}?=${PUB_REGEX}))
$(foreach site,${PUB_SITES},$(eval MKTMPDIR-${site}?=${MKTMPDIR}))
define chown_and_chmod
CHOWN-$(1)?=  ${CHOWN}
CHMOD-$(1)?=  ${CHMOD}
endef
$(foreach site,${PUB_SITES},$(eval $(call chown_and_chmod,${site})))
.PHONY: publish
publish: $(foreach site,${PUB_SITES},publish-${site})
ifeq (${PUB_AUTOTAG},true)
publish: autotag
else ifeq (${PUB_AUTOCOMMIT},true)
publish: autocommit
endif
define publish_target
.PHONY: publish-$(1)
publish-$(1): $(foreach file,${PUB_FILES-$(1)},${file})
	$$(call publish-${PUB_METHOD-$(1)},$(1))
endef

$(foreach site,${PUB_SITES},$(eval $(call publish_target,${site})))
define chown
$(if ${PUB_GROUP-$(1)},\
  ${SSH} ${PUB_SERVER-$(1)}\
  ${CHOWN} ${PUB_USER-$(1)}:$(strip ${PUB_GROUP-$(1)})\
  $(foreach f,${PUB_FILES-$(1)},${PUB_DIR-$(1)}/$f );\
  ,)
endef
define chmod
$(if ${PUB_CHMOD-$(1)},\
  ${SSH} ${PUB_SERVER-$(1)}\
  ${CHMOD} ${PUB_CHMOD-$(1)}\
  $(foreach f,${PUB_FILES-$(1)},${PUB_DIR-$(1)}/$f );\
  ,)
endef
define publish-ssh
${SSH} ${PUB_SERVER-$(1)} ${MKDIR} ${PUB_DIR-$(1)}; \
[ -n "${PUB_FILES-$(1)}" ] && find ${PUB_FILES-$(1)} -type f -or -type l | \
xargs ${PAX} \
  $(foreach regex,${PUB_REGEX-$(1)},-s ${regex}) \
  -s "|^.*/$(strip ${PUB_IGNORE-$(1)})/.*$$||p" | \
${SSH} ${PUB_SERVER-$(1)} ${UNPAX} \
  -s "\"|^|$(strip ${PUB_DIR-$(1)})/|p\""; \
$(call chown,$(1)) \
$(call chmod,$(1))
endef
define publish-at
${SSH} ${PUB_SERVER-$(1)} ${MKDIR} ${PUB_DIR-$(1)}; \
TMPPUB=$$(${SSH} ${PUB_SERVER-$(1)} "export TMPDIR=${PUB_TMPDIR-$(1)} && \
  ${MKTMPDIR-$(1)}"); \
[ -n "${PUB_FILES-$(1)}" ] && find ${PUB_FILES-$(1)} -type f -or -type l | \
xargs ${PAX} \
  $(foreach regex,${PUB_REGEX-$(1)},-s ${regex}) \
  -s "|^.*/$(strip ${PUB_IGNORE-$(1)})/.*$$||p" | \
${SSH} ${PUB_SERVER-$(1)} ${UNPAX} \
  -s "\"|^|$${TMPPUB}/|p\""; \
${SSH} ${PUB_SERVER-$(1)} "cd $${TMPPUB} && (\
  echo 'mv ${PUB_FILES-$(1)} ${PUB_DIR-$(2)};' \
  $(if ${PUB_CHMOD-$(1)},\
    echo '${CHMOD-$(1)} ${PUB_CHMOD-$(1)} ${PUB_DIR-$(1)};',) \
  $(if ${PUB_GROUP-$(1)},\
    echo '${CHOWN-$(1)} ${PUB_USER-$(1)}:$(strip ${PUB_GROUP-$(1)}) ${PUB_DIR-$(1)};',) \
  ) | at ${PKG_AT}"
endef
define publish-git
git archive ${PUB_BRANCH-$(1)} ${PUB_FILES-$(1)} \
  | ${SSH} ${PUB_SERVER-$(1)} ${UNPAX} -s ",^,$(strip ${PUB_DIR-$(1)}),"; \
$(call chown,$(1)) \
$(call chmod,$(1))
endef
autocommit-git = git diff --quiet || git commit ${PUB_COMMIT_OPTS}
autocommit-svn = svn commit ${PUB_COMMIT_OPTS}
autocommit-cvs = cvs commit ${PUB_COMMIT_OPTS}
autotag-git = git tag ${PUB_TAG_OPTS} ${PUB_TAG_NAME}
autotag-cvs = cvs tag ${PUB_TAG_OPTS} ${PUB_TAG_NAME}
define exit_if_fs_root
if [ $(stat -c %i $(1)) = $(stat -c %i /) \
     -a $(stat -c %d $(1)) = $(stat -c %d /) ]; then \
    exit 1; \
fi
endef

define autotag-svn
ROOT=.
while ! [ -d $${ROOT}/trunk ]; do \
  $(call exit_if_fs_root,$${ROOT})
  ROOT=$${ROOT}/.. \
done \
cd ${ROOT} \
  && svn copy trunk tags/${PUB_TAG_NAME} \
  && svn commit ${PUB_COMMIT_OPTS};
endef

.PHONY: autocommit
autocommit:
	$(call autocommit-${PUB_VCS})

.PHONY: autotag
autotag:
	$(call autotag-${PUB_VCS})

endif
