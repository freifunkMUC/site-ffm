#!/bin/bash
set -eEu
set -o pipefail

# file that contains the module information
MODULES_FILE="modules"

if ((BASH_VERSINFO[0] < 4)); then
    echo "This script requires Bash 4.0 or above."
    exit 1
fi

function get_value_from_line() {
    cat | cut -d '=' -f 2
}

function get_all_repo_names() {
    local file=$1
    grep "^GLUON_SITE_FEEDS" "${file}" | get_value_from_line | tr -d "'"
}

for repo in $(get_all_repo_names "${MODULES_FILE}"); do
    REPO_URL=$(grep "^PACKAGES_${repo^^}_REPO" "${MODULES_FILE}" | get_value_from_line)
    REPO_COMMIT=$(grep "^PACKAGES_${repo^^}_COMMIT" "${MODULES_FILE}" | get_value_from_line)
    REPO_BRANCH=$(grep "^PACKAGES_${repo^^}_BRANCH" "${MODULES_FILE}" | get_value_from_line)

    # Get newest commit of the repo
    NEW_COMMIT=$(git ls-remote --heads "${REPO_URL}" "${REPO_BRANCH}" | grep -oE '[0-9a-f]{40}')

    # Check if the commit has changed
    if [[ "${REPO_COMMIT}" == "${NEW_COMMIT}" ]]; then
        echo "No updates for ${repo} repository"
        continue
    fi

    # Update the value of the commit
    sed -i "s/${REPO_COMMIT}/${NEW_COMMIT}/" "${MODULES_FILE}"
    echo "Updated commit of ${repo} (${REPO_COMMIT}) to the newest commit (${NEW_COMMIT})."
done
