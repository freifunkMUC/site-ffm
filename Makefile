GLUON_BUILD_DIR := gluon-build
GLUON_GIT_URL := git://github.com/freifunk-gluon/gluon.git
GLUON_GIT_REF := a8b7c39078aa70291cf5af022f520b624b8f58aa

JOBS ?= $(shell cat /proc/cpuinfo | grep processor | wc -l)

_GIT_DESCRIBE = $(shell git describe --tags 2>&1)
ifneq (,${_GIT_DESCRIBE})
  GLUON_RELEASE := ${_GIT_DESCRIBE}
endif

all: build

build: gluon-prepare
	(cd ${GLUON_BUILD_DIR} && make update && make -j ${JOBS})

${GLUON_BUILD_DIR}:
	git clone ${GLUON_GIT_URL} ${GLUON_BUILD_DIR}

gluon-prepare: ${GLUON_BUILD_DIR}
	(cd ${GLUON_BUILD_DIR} && git checkout -q ${GLUON_GIT_REF})
	ln -sfT .. ${GLUON_BUILD_DIR}/site

clean:
	rm -rf ${GLUON_BUILD_DIR}
