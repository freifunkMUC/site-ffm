#!/usr/bin/env bash

set -eo pipefail

# move to basedir, in case the script is not executed via `make update-modules`
cd "$(dirname "$0")/../.." || exit 1

# shellcheck source=./modules
source ./modules

git diff --quiet ./modules || {
	1>&2 echo "Your modules file is dirty, aborting."
	exit 1
}


for MODULE in ${GLUON_SITE_FEEDS}; do
	_REMOTE_URL=PACKAGES_${MODULE^^}_REPO
	_REMOTE_BRANCH=PACKAGES_${MODULE^^}_BRANCH
	_LOCAL_HEAD=PACKAGES_${MODULE^^}_COMMIT

	REMOTE_URL="${!_REMOTE_URL}"
	REMOTE_BRANCH="${!_REMOTE_BRANCH}"
	LOCAL_HEAD="${!_LOCAL_HEAD}"

	# get default branch name if none is set
	[ -z "${REMOTE_BRANCH}" ] && {
		REMOTE_BRANCH=$(git ls-remote --symref "${REMOTE_URL}" HEAD | awk '/^ref:/ { sub(/refs\/heads\//, "", $2); print $2 }')
	}

	# fetch the commit id for the HEAD of the module
	REMOTE_HEAD=$(git ls-remote "${REMOTE_URL}" "${REMOTE_BRANCH}" | awk '{ print $1 }')

	# skip ahead if the commit id did not change
	[ "$LOCAL_HEAD" == "$REMOTE_HEAD" ] && continue 1



	CHECKOUT=$(mktemp -d)

	# clone the target branch
	git clone --bare "${REMOTE_URL}" --branch="${REMOTE_BRANCH}" "${CHECKOUT}"

	# prepare the commit message
	# shellcheck disable=SC2001
	MODULE=$(echo "${MODULE,,}" | sed 's/packages_//')
	TITLE="modules: update ${MODULE}"
	MESSAGE="$(mktemp)"
	{
		echo "${TITLE}"
		printf '\n\n'
		git -C "${CHECKOUT}" log --oneline --no-decorate --no-merges "${LOCAL_HEAD}..${REMOTE_HEAD}" | cat
	} > "$MESSAGE"

	# modify modules file
	sed -i "s/${LOCAL_HEAD}/${REMOTE_HEAD}/" ./modules
	git add ./modules

	git commit -F "${MESSAGE}"

	# remove the checkout
	rm -fr "${CHECKOUT}"
done
