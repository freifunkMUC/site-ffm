GLUON_MULTIDOMAIN=1
GLUON_DEPRECATED=upgrade

DEFAULT_GLUON_RELEASE := v2021.6.0~exp$(shell date '+%Y%m%d%H')

# Allow overriding the release number from the command line
GLUON_RELEASE ?= $(DEFAULT_GLUON_RELEASE)

GLUON_PRIORITY ?= 0

GLUON_REGION ?= eu

# Languages to include
GLUON_LANGS ?= en de
