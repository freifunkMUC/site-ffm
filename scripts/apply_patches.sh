#!/usr/bin/env bash

set -eEu
set -o pipefail
shopt -s nullglob

gluon_build_dir=${1:-gluon-build}
gluon_patch_dir="${2:-patches}"

function reset_gluon_build_dir() {
    # Make sure we are in the correct folder
    if [[ ! $(pwd) =~ .*${gluon_build_dir} ]]; then
        echo "Resetting environment in the wrong folder. Aborting."
        return 1
    fi
    echo "Resetting environment."

    # Reset all files known to git, but keep manually commited changes.
    git checkout .
    # Delete all files not known to git
    git clean -dx --force
    echo "Environment reset."
}

# Relative patches folder does not work with git-apply below. Make sure it is an absolute path.
if [[ ! ${gluon_patch_dir} =~ ^/ ]]; then
    gluon_patch_dir="${PWD}/${gluon_patch_dir}"
    echo "Setting patch directory to ${gluon_patch_dir}"
fi

pushd "${gluon_build_dir}"

# Check if there are any patches at all
if ! compgen -G "${gluon_patch_dir}/*.patch" >/dev/null; then
    echo "No patches found in ${gluon_patch_dir}/*.patch"
    exit 1
fi

# Reset previously applied patches
reset_gluon_build_dir

# Apply all patches
echo "Applying Patches."
if ! git apply --ignore-space-change --ignore-whitespace --whitespace=nowarn --verbose "${gluon_patch_dir}"/*.patch; then
    echo "Patching failed. Inspect ${gluon_build_dir} folder for failed patches."
    exit 1
fi

echo "Patching finished."
popd
