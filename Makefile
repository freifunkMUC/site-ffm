GLUON_BUILD_DIR := gluon-build
GLUON_GIT_URL := https://github.com/freifunk-gluon/gluon.git
GLUON_GIT_REF := v2021.1.2

PATCH_DIR := ./patches
SECRET_KEY_FILE ?= ${HOME}/.gluon-secret-key

GLUON_TARGETS ?= \
	ar71xx-generic \
	ar71xx-mikrotik \
	ar71xx-nand \
	ar71xx-tiny \
	ath79-generic \
	brcm2708-bcm2708 \
	brcm2708-bcm2709 \
	brcm2708-bcm2710 \
	ipq40xx-generic \
	ipq806x-generic \
	lantiq-xrx200 \
	lantiq-xway \
	mpc85xx-generic \
	mpc85cc-p1020 \
	mvebu-cortexa9 \
	ramips-mt7620 \
	ramips-mt7621 \
	ramips-mt76x8 \
	ramips-rt305x \
	sunxi-cortexa7 \
	x86-64 \
	x86-generic \
	x86-geode \
	x86-legacy

GLUON_AUTOUPDATER_BRANCH := stable

ifneq (,$(shell git describe --exact-match --tags 2>/dev/null))
	GLUON_AUTOUPDATER_ENABLED := 1
	GLUON_RELEASE := $(shell git describe --tags 2>/dev/null)
else
	GLUON_AUTOUPDATER_ENABLED := 0
	EXP_FALLBACK = $(shell date '+%Y%m%d')
	BUILD_NUMBER ?= $(EXP_FALLBACK)
	GLUON_RELEASE := $(shell git describe --tags)~exp$(BUILD_NUMBER)
endif

JOBS ?= $(shell cat /proc/cpuinfo | grep processor | wc -l)

GLUON_MAKE := ${MAKE} -j ${JOBS} -C ${GLUON_BUILD_DIR} \
	GLUON_RELEASE=${GLUON_RELEASE} \
	GLUON_AUTOUPDATER_BRANCH=${GLUON_AUTOUPDATER_BRANCH} \
	GLUON_AUTOUPDATER_ENABLED=${GLUON_AUTOUPDATER_ENABLED}

all: info
	${MAKE} manifest

info:
	@echo
	@echo '#########################'
	@echo '# FFMUC Firmware build'
	@echo '# Building release ${GLUON_RELEASE} for branch ${GLUON_AUTOUPDATER_BRANCH}'
	@echo

build: gluon-prepare output-clean
	for target in ${GLUON_TARGETS}; do \
		echo ""Building target $$target""; \
		${GLUON_MAKE} download all GLUON_TARGET="$$target"; \
	done

manifest: build
	for branch in experimental testing stable; do \
		${GLUON_MAKE} manifest GLUON_AUTOUPDATER_BRANCH=$$branch;\
	done
	mv -f ${GLUON_BUILD_DIR}/output/* ./output/

sign: manifest
	${GLUON_BUILD_DIR}/contrib/sign.sh ${SECRET_KEY_FILE} output/images/sysupgrade/${GLUON_AUTOUPDATER_BRANCH}.manifest

${GLUON_BUILD_DIR}:
	mkdir -p ${GLUON_BUILD_DIR}

# Note: "|" means "order only", e.g. "do not care about folder timestamps"
# https://www.gnu.org/savannah-checkouts/gnu/make/manual/html_node/Prerequisite-Types.html
${GLUON_BUILD_DIR}/.git: | ${GLUON_BUILD_DIR}
	git init ${GLUON_BUILD_DIR}
	cd ${GLUON_BUILD_DIR} && git remote add origin ${GLUON_GIT_URL}

gluon-update: | ${GLUON_BUILD_DIR}/.git
	cd ${GLUON_BUILD_DIR} && git fetch --tags origin ${GLUON_GIT_REF}
	cd ${GLUON_BUILD_DIR} && git reset --hard FETCH_HEAD
	cd ${GLUON_BUILD_DIR} && git clean -ffdx packages/ # double -f -f required to remove sub-repositories
	cd ${GLUON_BUILD_DIR} && git clean -fd

gluon-prepare: gluon-update
	make gluon-patch
	ln -sfT .. ${GLUON_BUILD_DIR}/site
	${GLUON_MAKE} update

gluon-patch:
	scripts/apply_patches.sh ${GLUON_BUILD_DIR} ${PATCH_DIR}

gluon-clean:
	rm -rf ${GLUON_BUILD_DIR}

output-clean:
	mkdir -p output/
	rm -rf output/*

clean: gluon-clean output-clean
