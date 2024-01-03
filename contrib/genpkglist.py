#!/usr/bin/env python3
import os
from collections import defaultdict

from jinja2 import Template

# path to your gluon checkout, will be used to find targets and devices
GLUON_DIR = './gluon-build/'


class PackageList:
    def __init__(self, name: str, pkgs: list):
        self.name = name
        self.pkgs = pkgs

    def __repr__(self):
        return self.name

    def __lt__(self, other):
        return self.name < other.name

    def render(self):
        return Template("""
INCLUDE_{{ name }} := \\
{%- for pkg in pkgs %}
    {{ pkg }}{% if not loop.last %} \\{% endif %}
{%- endfor %}

EXCLUDE_{{ name }} := \\
{%- for pkg in pkgs %}
    -{{ pkg }}{% if not loop.last %} \\{% endif %}
{%- endfor %}""").render(
            name=self.name,
            pkgs=self.pkgs
        )


class Target:
    def __init__(self, name):
        self.name = name
        self.devices = set()
        self.pkglists = set()
        self.excludes = defaultdict(set)
        self.includes = defaultdict(set)

    def add_device(self, device: str):
        self.devices.add(device)

    def add_pkglist(self, pkglist: PackageList):
        self.pkglists.add(pkglist)
        return self

    def include(self, devices: [str], pkglists: [PackageList]=None):
        for device in devices:
            assert(device in self.devices), "Device %s not in target %s" % (device, self.name)
            if not pkglists:
                self.includes[device] = self.pkglists
            else:
                self.includes[device] = self.includes[device].union(pkglists)

        return self

    def exclude(self, devices: [str], pkglists: [PackageList]=None):
        for device in devices:
            assert(device in self.devices), "Device %s not in target %s" % (device, self.name)
            if not pkglists:
                self.excludes[device] = self.pkglists
            else:
                self.excludes[device] = self.excludes[device].union(pkglists)

        return self

    def render(self):
        if not bool(self.includes) and not self.pkglists:
            return """
# no pkglists for target %s
""" % self.name

        return Template("""
ifeq ($(GLUON_TARGET),{{ target }})
    GLUON_SITE_PACKAGES += {% for pkglist in pkglists %}$(INCLUDE_{{ pkglist.name }}){% if not loop.last %} {% endif %}{% endfor %}
{% for device, include in includes.items() %}
    GLUON_{{ device }}_SITE_PACKAGES += {% for pkglist in include|sort %}$(INCLUDE_{{ pkglist.name }}){% if not loop.last %} {% endif %}{% endfor %}
{%- endfor %}{% for device, exclude in excludes.items() %}
    GLUON_{{ device }}_SITE_PACKAGES += {% for pkglist in exclude|sort %}$(EXCLUDE_{{ pkglist.name }}){% if not loop.last %} {% endif %}{% endfor %}
{%- endfor %}
endif""").render(
            target=self.name,
            pkglists=sorted(self.pkglists),
            excludes=self.excludes,
            includes=self.includes
        )


targets = {}
targetdir = os.path.join(GLUON_DIR, 'targets')
for targetfile in os.listdir(targetdir):
    if targetfile in ['generic', 'targets.mk'] or targetfile.endswith('.inc'):
        continue

    target = Target(targetfile)
    with open(os.path.join(targetdir, targetfile)) as handle:
        for line in handle.readlines():
            if line.startswith('device'):
                target.add_device(line.split('\'')[1])

    targets[targetfile] = target


#
# package definitions
#

pkglists = []

PKGS_USB = PackageList('USB', ['usbutils'])
pkglists.append(PKGS_USB)

PKGS_USB_HID = PackageList('USB_HID', [
    'kmod-usb-hid',
    'kmod-hid-generic'
])
pkglists.append(PKGS_USB_HID)

PKGS_USB_SERIAL = PackageList('USB_SERIAL', [
    'kmod-usb-serial',
    'kmod-usb-serial-ftdi',
    'kmod-usb-serial-pl2303'
])
pkglists.append(PKGS_USB_SERIAL)

PKGS_USB_STORAGE = PackageList('USB_STORAGE', [
    'block-mount',
    'blkid',
    'kmod-fs-ext4',
    'kmod-fs-ntfs',
    'kmod-fs-vfat',
    'kmod-usb-storage',
    'kmod-usb-storage-extras',  # Card Readers
    'kmod-usb-storage-uas',     # USB Attached SCSI (UAS/UASP)
    'kmod-nls-base',
    'kmod-nls-cp1250',          # NLS Codepage 1250 (Eastern Europe)
    'kmod-nls-cp437',           # NLS Codepage 437 (United States, Canada)
    'kmod-nls-cp850',           # NLS Codepage 850 (Europe)
    'kmod-nls-cp852',           # NLS Codepage 852 (Europe)
    'kmod-nls-iso8859-1',       # NLS ISO 8859-1 (Latin 1)
    'kmod-nls-iso8859-13',      # NLS ISO 8859-13 (Latin 7; Baltic)
    'kmod-nls-iso8859-15',      # NLS ISO 8859-15 (Latin 9)
    'kmod-nls-iso8859-2',       # NLS ISO 8859-2 (Latin 2)
    'kmod-nls-utf8'             # NLS UTF-8
])
pkglists.append(PKGS_USB_STORAGE)

PKGS_USB_NET = PackageList('USB_NET', [
    'kmod-mii',
    'kmod-usb-net',
    'kmod-usb-net-asix',
    'kmod-usb-net-asix-ax88179',
    'kmod-usb-net-cdc-eem',
    'kmod-usb-net-cdc-ether',
    'kmod-usb-net-cdc-subset',
    'kmod-usb-net-dm9601-ether',
    'kmod-usb-net-hso',
    'kmod-usb-net-ipheth',
    'kmod-usb-net-mcs7830',
    'kmod-usb-net-pegasus',
    'kmod-usb-net-rndis',
    'kmod-usb-net-rtl8152',
    'kmod-usb-net-smsc95xx'
])
pkglists.append(PKGS_USB_NET)

PKGS_PCI = PackageList('PCI', ['pciutils'])
pkglists.append(PKGS_PCI)

PKGS_PCI_NET = PackageList('PCI_NET', [
    'kmod-bnx2'  # Broadcom NetExtreme BCM5706/5708/5709/5716
])
pkglists.append(PKGS_PCI_NET)

PKGS_VIRT = PackageList('VIRT', ['qemu-ga'])
pkglists.append(PKGS_VIRT)

PKGS_TLS = PackageList('TLS', [
    'ca-bundle',
    'libustream-openssl'
])
pkglists.append(PKGS_TLS)

PKGS_NSM = PackageList('NSM', [
    'ffda-network-setup-mode',
])
pkglists.append(PKGS_NSM)

#
# package assignment
#

targets['ath79-generic']. \
    add_pkglist(PKGS_TLS). \
    include([ # 7M usable firmware space + USB port
        'devolo-wifi-pro-1750e',
        'gl.inet-gl-ar150',
        'gl.inet-gl-ar300m-lite',
        'gl.inet-gl-ar750',
        'joy-it-jt-or750i',
        'netgear-wndr3700-v2',
        'tp-link-archer-a7-v5',
        'tp-link-archer-c5-v1',
        'tp-link-archer-c7-v2',
        'tp-link-archer-c7-v5',
        'tp-link-archer-c59-v1',
        'tp-link-tl-wr842n-v3',
        'tp-link-tl-wr1043nd-v4',
    ], pkglists=[PKGS_USB, PKGS_USB_NET, PKGS_USB_SERIAL, PKGS_USB_STORAGE]). \
    exclude([
        'd-link-dir825b1',
    ], pkglists=[PKGS_TLS])

for target in [
    "ath79-mikrotik",
    "ath79-nand",
    "ipq40xx-generic",
    "ipq40xx-mikrotik",
    "ipq806x-generic",
    "lantiq-xway",
    "mpc85xx-p1010",
    "mpc85xx-p1020",
    "mvebu-cortexa9",
    "rockchip-armv8",
    "sunxi-cortexa7",
]:
    targets[target]. \
        add_pkglist(PKGS_USB). \
        add_pkglist(PKGS_USB_NET). \
        add_pkglist(PKGS_USB_SERIAL). \
        add_pkglist(PKGS_USB_STORAGE). \
        add_pkglist(PKGS_TLS)

targets['lantiq-xrx200']. \
        add_pkglist(PKGS_USB). \
        add_pkglist(PKGS_USB_NET). \
        add_pkglist(PKGS_USB_SERIAL). \
        add_pkglist(PKGS_USB_STORAGE). \
        add_pkglist(PKGS_TLS). \
        exclude([ # 7M usable firmware space + USB port
            'avm-fritz-box-7412',
            'tp-link-td-w8970',
            'tp-link-td-w8980'
        ], pkglists=[PKGS_USB, PKGS_USB_NET, PKGS_USB_SERIAL, PKGS_USB_STORAGE])

targets['mpc85xx-p1020'].add_pkglist(PKGS_TLS)

for target in ['bcm27xx-bcm2708', 'bcm27xx-bcm2709', 'bcm27xx-bcm2710', 'bcm27xx-bcm2711']:
    targets[target]. \
        add_pkglist(PKGS_USB). \
        add_pkglist(PKGS_USB_NET). \
        add_pkglist(PKGS_USB_SERIAL). \
        add_pkglist(PKGS_USB_STORAGE). \
        add_pkglist(PKGS_USB_HID). \
        add_pkglist(PKGS_TLS)

targets['mediatek-mt7622']. \
    add_pkglist(PKGS_USB). \
    add_pkglist(PKGS_USB_NET). \
    add_pkglist(PKGS_USB_SERIAL). \
    add_pkglist(PKGS_USB_STORAGE). \
    add_pkglist(PKGS_TLS). \
    exclude([  # devices without usb ports
        'ubiquiti-unifi-6-lr-v1'], pkglists=[PKGS_USB, PKGS_USB_NET, PKGS_USB_SERIAL, PKGS_USB_STORAGE])

targets['ramips-mt7621']. \
    add_pkglist(PKGS_USB). \
    add_pkglist(PKGS_USB_NET). \
    add_pkglist(PKGS_USB_SERIAL). \
    add_pkglist(PKGS_USB_STORAGE). \
    add_pkglist(PKGS_TLS). \
    include(['zyxel-nwa55axe'], pkglists=[PKGS_NSM]). \
    exclude([  # devices without usb ports
        'netgear-ex6150',
        'ubiquiti-edgerouter-x',
        'ubiquiti-edgerouter-x-sfp',
        'zyxel-nwa55axe',
    ], pkglists=[PKGS_USB, PKGS_USB_NET, PKGS_USB_SERIAL, PKGS_USB_STORAGE])

targets['ramips-mt7620']. \
    add_pkglist(PKGS_USB). \
    add_pkglist(PKGS_USB_NET). \
    add_pkglist(PKGS_USB_SERIAL). \
    add_pkglist(PKGS_USB_STORAGE). \
    add_pkglist(PKGS_TLS). \
    exclude([  # devices without usb ports
        'netgear-ex3700'], pkglists=[PKGS_USB, PKGS_USB_NET, PKGS_USB_SERIAL, PKGS_USB_STORAGE])

targets['ramips-mt76x8']. \
    add_pkglist(PKGS_TLS). \
    include([ # 7M usable firmware space + USB port
        'gl-mt300n-v2',
        'gl.inet-microuter-n300',
        'netgear-r6120',
        'ravpower-rp-wd009'], pkglists=[PKGS_USB, PKGS_USB_NET, PKGS_USB_SERIAL, PKGS_USB_STORAGE]). \
    exclude([
    ], pkglists=[PKGS_TLS])

for target in ['x86-64', 'x86-generic', 'x86-geode']:
    targets.get(target). \
        add_pkglist(PKGS_USB). \
        add_pkglist(PKGS_USB_NET). \
        add_pkglist(PKGS_USB_SERIAL). \
        add_pkglist(PKGS_USB_STORAGE). \
        add_pkglist(PKGS_PCI). \
        add_pkglist(PKGS_PCI_NET). \
        add_pkglist(PKGS_TLS)

targets.get('x86-legacy').add_pkglist(PKGS_TLS)

if __name__ == '__main__':
    for pkglist in pkglists:
        print(pkglist.render())

    for target in sorted(targets.values(), key=lambda x: x.name):
        print(target.render())
