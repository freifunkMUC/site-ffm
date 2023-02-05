#!/bin/sh

# Copyright (c) Project Gluon
# All rights reserved.

# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:

#   1. Redistributions of source code must retain the above copyright notice,
#      this list of conditions and the following disclaimer.
#   2. Redistributions in binary form must reproduce the above copyright notice,
#      this list of conditions and the following disclaimer in the documentation
#      and/or other materials provided with the distribution.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# SPDX-License-Identifier: BSD-2-Clause

set -e

if [ $# -ne 2 ] || [ "-h" = "$1" ] || [ "--help" = "$1" ] || [ ! -r "$1" ] || [ ! -r "$2" ]; then
	cat <<EOHELP
Usage: $0 <secret> <manifest>

sign.sh adds lines to a manifest to indicate the approval
of the integrity of the firmware as required for automated
updates. The first argument <secret> references a file harboring
the private key of a public-private key pair of a developer
that referenced by its public key in the site configuration.
The script may be performed multiple times to the same document
to indicate an approval by multiple developers.

See also
 * ecdsautils on https://github.com/freifunk-gluon/ecdsautils

EOHELP
	exit 1
fi

SECRET="$1"

manifest="$2"
upper="$(mktemp)"
lower="$(mktemp)"

trap 'rm -f "$upper" "$lower"' EXIT

awk 'BEGIN    {
	sep = 0
}

/^---$/ {
	sep = 1;
	next
}

{
	if(sep == 0) {
		print > "'"$upper"'"
	} else {
		print > "'"$lower"'"
	}
}' "$manifest"

ecdsasign "$upper" < "$SECRET" >> "$lower"

(
	cat  "$upper"
	echo ---
	cat  "$lower"
) > "$manifest"
