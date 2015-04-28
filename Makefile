GLUON_BUILD_DIR := gluon-build
GLUON_GIT_URL := https://github.com/freifunk-gluon/gluon.git
GLUON_GIT_REF := 6bcd9b92d494f29de0d5d2bc41643d2d35ffc530

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
	${GLUON_MAKE} GLUON_TARGET=ar71xx-generic
	${GLUON_MAKE} GLUON_TARGET=ar71xx-nand
	${GLUON_MAKE} GLUON_TARGET=mpc85xx-generic
	${GLUON_MAKE} GLUON_TARGET=x86-kvm_guest

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
