GLUON_BUILD_DIR := gluon-build
GLUON_GIT_URL := git://github.com/freifunk-gluon/gluon.git
GLUON_GIT_REF := v2014.4

SECRET_KEY_FILE ?= ${HOME}/.gluon-secret-key

_GIT_DESCRIBE = $(shell git describe --tags 2>/dev/null)
ifneq (,${_GIT_DESCRIBE})
  GLUON_RELEASE := ${_GIT_DESCRIBE}
  GLUON_BRANCH := stable
else
  GLUON_RELEASE ?= snapshot~$(shell date '+%Y%m%d')~$(shell git describe --always)
  GLUON_BRANCH := experimental
endif

JOBS ?= $(shell cat /proc/cpuinfo | grep processor | wc -l)

GLUON_MAKE := ${MAKE} -j ${JOBS} -C ${GLUON_BUILD_DIR} \
                      GLUON_RELEASE=${GLUON_RELEASE} \
                      GLUON_BRANCH=${GLUON_BRANCH}

all: gluon-clean
	${MAKE} manifest
	${MAKE} gluon-clean

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
