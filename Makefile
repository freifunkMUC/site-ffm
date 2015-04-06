GLUON_BUILD_DIR := gluon-build
GLUON_GIT_URL := https://github.com/freifunkMUC/gluon.git
GLUON_GIT_REF := 52698e62bac2ec0f8764b12cf437040528e77efb

SECRET_KEY_FILE ?= ${HOME}/.gluon-secret-key

GLUON_RELEASE := $(shell git describe --tags 2>/dev/null)
ifneq (,$(shell git describe --exact-match --tags 2>/dev/null))
  GLUON_BRANCH := stable
else
  GLUON_BRANCH := experimental
endif

JOBS ?= $(shell cat /proc/cpuinfo | grep processor | wc -l)

GLUON_MAKE := ${MAKE} -j ${JOBS} -C ${GLUON_BUILD_DIR} \
                      GLUON_RELEASE=${GLUON_RELEASE} \
                      GLUON_BRANCH=${GLUON_BRANCH}

all: info
	${MAKE} gluon-clean
	${MAKE} manifest
	${MAKE} gluon-clean

info:
	@echo
	@echo '#########################'
	@echo '# FFMUC Firmare build'
	@echo '# Building release ${GLUON_RELEASE} for branch ${GLUON_BRANCH}'
	@echo

build: gluon-prepare
	${GLUON_MAKE}

manifest: build
	${GLUON_MAKE} manifest
	mv ${GLUON_BUILD_DIR}/images .

sign: manifest
	${GLUON_BUILD_DIR}/contrib/sign.sh ${SECRET_KEY_FILE} images/sysupgrade/${GLUON_BRANCH}.manifest

${GLUON_BUILD_DIR}:
	git clone ${GLUON_GIT_URL} ${GLUON_BUILD_DIR}

gluon-prepare: images-clean ${GLUON_BUILD_DIR}
	(cd ${GLUON_BUILD_DIR} && git fetch origin && git checkout -q ${GLUON_GIT_REF})
	ln -sfT .. ${GLUON_BUILD_DIR}/site
	${GLUON_MAKE} update

gluon-clean:
	rm -rf ${GLUON_BUILD_DIR}

images-clean:
	rm -rf images

clean: gluon-clean images-clean
