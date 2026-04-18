#nwipe

NWIPE_VERSION = v0.40
NWIPE_SOURCE = nwipe-$(NWIPE_VERSION).tar.gz
NWIPE_SITE = $(call github,martijnvanbrummelen,nwipe,$(NWIPE_VERSION))

NWIPE_LICENSE = GPL-2.0+
NWIPE_LICENSE_FILES = COPYING
NWIPE_DEPENDENCIES = ncurses parted libconfig util-linux
NWIPE_AUTORECONF = YES

$(eval $(autotools-package))
