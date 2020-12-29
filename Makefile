GLUON_BUILD_DIR := gluon-build
GLUON_GIT_URL := https://github.com/freifunk-gluon/gluon.git
GLUON_GIT_REF := v2020.2.2

PATCH_DIR := ${GLUON_BUILD_DIR}/site/patches
SECRET_KEY_FILE ?= ${HOME}/.gluon-secret-key

GLUON_TARGETS ?= \
	ar71xx-generic \
	ar71xx-tiny \
	ar71xx-nand \
	brcm2708-bcm2708 \
	brcm2708-bcm2709 \
	mpc85xx-generic \
	mpc85cc-p1020 \
	lantiq-xway \
	lantiq-xrx200 \
	ath79-generic \
	ramips-mt7621 \
	sunxi-cortexa7 \
	x86-generic \
	x86-geode \
	x86-64 \
	x86-legacy \
	ipq40xx-generic \
	ipq806x-generic \
	ramips-mt7620 \
	ramips-mt76x8 \
	ramips-rt305x

ifneq (,$(shell git describe --exact-match --tags 2>/dev/null))
	GLUON_BRANCH := stable
	GLUON_RELEASE := $(shell git describe --tags 2>/dev/null)
else
	GLUON_BRANCH := experimental
	EXP_FALLBACK = $(shell date '+%Y%m%d%H')
	BUILD_NUMBER ?= $(EXP_FALLBACK)
	GLUON_RELEASE := v2020.3.2.1~exp$(BUILD_NUMBER)
endif

JOBS ?= $(shell cat /proc/cpuinfo | grep processor | wc -l)

GLUON_MAKE := ${MAKE} -j ${JOBS} -C ${GLUON_BUILD_DIR} \
	GLUON_RELEASE=${GLUON_RELEASE} \
	GLUON_BRANCH=${GLUON_BRANCH}

all: info
	${MAKE} manifest

info:
	@echo
	@echo '#########################'
	@echo '# FFMUC Firmware build'
	@echo '# Building release ${GLUON_RELEASE} for branch ${GLUON_BRANCH}'
	@echo

build: gluon-prepare
	for target in ${GLUON_TARGETS}; do \
		echo ""Building target $$target""; \
		${GLUON_MAKE} download all GLUON_TARGET="$$target"; \
	done

manifest: build
	${GLUON_MAKE} manifest
	mv ${GLUON_BUILD_DIR}/output .

sign: manifest
	${GLUON_BUILD_DIR}/contrib/sign.sh ${SECRET_KEY_FILE} output/images/sysupgrade/${GLUON_BRANCH}.manifest

${GLUON_BUILD_DIR}:
	git clone ${GLUON_GIT_URL} ${GLUON_BUILD_DIR}

gluon-prepare: output-clean ${GLUON_BUILD_DIR}
	(cd ${GLUON_BUILD_DIR} \
		&& git remote set-url origin ${GLUON_GIT_URL} \
		&& git fetch origin \
		&& rm -rf package packages \
		&& git checkout -q --force ${GLUON_GIT_REF}) \
		&& git clean -fd
	ln -sfT .. ${GLUON_BUILD_DIR}/site
	make gluon-patch
	${GLUON_MAKE} update
gluon-patch:
	echo "Applying Patches ..."
	(cd ${GLUON_BUILD_DIR})
			if [ `git branch --list patched` ]; then \
				(git branch -D patched) \
			fi
	(cd ${GLUON_BUILD_DIR}; git checkout -B patching)
	if [ -d "gluon-build/site/patches" -a "gluon-build/site/patches/*.patch" ]; then \
		(cd ${GLUON_BUILD_DIR}; git apply --ignore-space-change --ignore-whitespace --whitespace=nowarn site/patches/*.patch) || ( \
			cd ${GLUON_BUILD_DIR} \
			git clean -fd \
			git am --abort \
			git checkout -B patched \
			git branch -D patching \
			false \
		) \
	fi
	(cd ${GLUON_BUILD_DIR}; git branch -M patched)

gluon-clean:
	rm -rf ${GLUON_BUILD_DIR}

output-clean:
	rm -rf output

clean: gluon-clean output-clean
