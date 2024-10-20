#!/usr/bin/lua

features{
    'autoupdater',
    'config-mode-domain-select',
    'config-mode-geo-location-osm',
    'config-mode-mesh-vpn',
    'mesh-batman-adv-15',
    'mesh-vpn-parker',
    'respondd',
    'status-page',
    'web-advanced',
    'web-private-wifi',
    'web-wizard',
}

packages{
    'ff-ap-timer',
    'ff-web-ap-timer',
    'ffac-autoupdater-wifi-fallback',
    'ffac-change-autoupdater',
    'ffac-ssid-changer',
    'ffbs-collect-debug-info',
    'gluon-ffbsnext-nodeconfig',
    'gluon-ffbsnext-nodeconfig-respondd',
    'gluon-ffbsnext-nextnode',
    '-gluon-ebtables-limit-arp',
    'iwinfo',
    'kmod-nat46',
    'respondd-module-airtime',
}

if not device_class('tiny') then
    features{
        'wireless-encryption-wpa3',
    }
    packages{
        'ffmuc-custom-banner',
    }
end

if device({
        'zte-mf281',
        'glinet-gl-xe300',
        'glinet-gl-ap1300',
        'zte-mf289f',
        'zte-mf286r',
        'wavlink-ws-wn572hp3-4g',
        'tp-link-tl-mr6400-v5',
    }) then
    features {
        'web-cellular',
    }
end

pkgs_usb = {
    'usbutils',
}

pkgs_hid = {
    'kmod-usb-hid',
    'kmod-hid-generic',
}

pkgs_usb_serial = {
    'kmod-usb-serial',
    'kmod-usb-serial-ftdi',
    'kmod-usb-serial-pl2303',
}

pkgs_usb_storage = {
    'block-mount',
    'blkid',
    'kmod-fs-ext4',
    'kmod-fs-ntfs',
    'kmod-fs-vfat',
    'kmod-usb-storage',
    'kmod-usb-storage-extras',-- Card Readers
    'kmod-usb-storage-uas', -- USB Attached SCSI (UAS/UASP)
    'kmod-nls-base',
    'kmod-nls-cp1250',      -- NLS Codepage 1250 (Eastern Europe)
    'kmod-nls-cp437',       -- NLS Codepage 437 (United States, Canada)
    'kmod-nls-cp850',       -- NLS Codepage 850 (Europe)
    'kmod-nls-cp852',       -- NLS Codepage 852 (Europe)
    'kmod-nls-iso8859-1',   -- NLS ISO 8859-1 (Latin 1)
    'kmod-nls-iso8859-13',  -- NLS ISO 8859-13 (Latin 7; Baltic)
    'kmod-nls-iso8859-15',  -- NLS ISO 8859-15 (Latin 9)
    'kmod-nls-iso8859-2',   -- NLS ISO 8859-2 (Latin 2)
    'kmod-nls-utf8',        -- NLS UTF-8
}

pkgs_usb_net = {
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
    'kmod-usb-net-smsc95xx',
}

pkgs_pci = {
    'pciutils',
    'kmod-bnx2', -- Broadcom NetExtreme BCM5706/5708/5709/5716
}

include_tls = not device({
    'd-link-dir825b1',
})

if include_tls then
    features({ 'tls' })
    packages({
        'openssh-sftp-server', -- for OpenSSH 9: https://www.openssh.com/txt/release-9.0
    })
end

include_usb = true

-- rtl838x has no USB support as of Gluon v2023.2
if target('realtek', 'rtl838x') then
    include_usb = false
end

-- exclude USB for ath79-generic except for a few  devices
if target('ath79', 'generic') and not device({
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
}) then
    include_usb = false
end

-- 7M usable firmware space + USB port
if device({
    'gl-mt300n-v2',
    'tp-link-td-w8970',
    'tp-link-td-w8980',
}) then
    include_usb = false
end

-- devices without usb ports
if device({
    'avm-fritz-box-7412',
    'gl.inet-microuter-n300',
    'netgear-ex3700',
    'netgear-ex6150',
    'netgear-r6020',
    'ubiquiti-edgerouter-x-sfp',
    'ubiquiti-edgerouter-x',
    'ubiquiti-unifi-6-lr-v1',
    'zyxel-nwa55axe',
}) then
    include_usb = false
end

if include_usb then
    packages(pkgs_usb)
    packages(pkgs_usb_net)
    packages(pkgs_usb_serial)
    packages(pkgs_usb_storage)
end

-- device has no reset button and requires a special package to go into setup mode
-- https://github.com/freifunk-gluon/community-packages/tree/master/ffda-network-setup-mode
if device({
    'zyxel-nwa55axe',
}) then
    packages {'ffda-network-setup-mode'}
end

if target('x86', '64') then
    packages {'qemu-ga'}
end

if target('x86') and not target('x86', 'legacy') then
    packages(pkgs_pci)
end

if target('bcm27xx') then
    packages(pkgs_hid)
end

if target('ramips', 'mt7621') or target('mediatek', 'mt7622') or target('mediatek', 'filogic') then
	-- restart device if mt7915e driver shows known failure symptom
	packages {
		'ffac-mt7915-hotfix',
	}
end
