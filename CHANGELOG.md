# Freifunk München Firmware Changelog

## v2019.1.3
  - Update to gluon 2019.1.2
    - https://gluon.readthedocs.io/en/latest/releases/v2019.1.2.html

## v2019.1.2
  - Update to gluon 2019.1.1
    - https://gluon.readthedocs.io/en/latest/releases/v2019.1.html

## v2019.1.1
  - Updated to Gluon v2019.1
    - https://gluon.readthedocs.io/en/latest/releases/v2019.1.html
  - remove patches to upgrade to batman-adv-v2019.2
  - fix Patch for respondd

## v2019.0.10
  - Updated to Gluon v2018.2.3
    - https://gluon.readthedocs.io/en/v2018.2.3/releases/v2018.2.3.html
  - add respondd-module-airtime to get stats about airtime usage

## v2019.0.9
  - Patches:
    - use wifi tx bitrate as fallback throughput
    - add kernel module required by simple-tc

## v2019.0.8
  - add ap-timer to allow setting on and off times for client wifi
  - update gluon to use batman-adv-v2019.2
  - Use Skript of ffda to determine which packages should be included in device firmware
  - Add sign key of @django

## v2019.0.7
  - Drop config for ffmuc_testing (not used anymore)
  - disable ath9k-broken-wifi-workaround
  - reset batman_adv.gw_sel_class to default (atm 5000)

## v2019.0.6
  - Updated to Gluon v2018.2.2
    - Changes: https://gluon.readthedocs.io/en/v2018.2.2/releases/v2018.2.2.html
  - Domains:
    - fix for muc_ost: Wrong prefix for local IP and duplicate domain_seed

## v2019.0.5
  - Domains:
    - add gw07 for new segments
    - remove legacy domains (will fallback to ffmuc_welt)
  - Docs:
    - remove hint to lqfb.freifunk-muenchen.de as it is offline
      (thanks to @T0biii in #59)
    - change url from ffmuc.net/map to map.ffmuc.net

## v2019.0.4
  - Domains:
    - add ffmuc_freising and ffmuc_gauting
  - Doc:
    - add hint to liquid feedback as it is offline for at least a year

## v2019.0.3

  - Domains:
    - add "ALT:" prefix for old/deprecated Segments
    - add domain-config for new segments
      - ffmuc_muc_cty, ffmuc_muc_nord, ffmuc_muc_ost, ffmuc_muc_sued,
        ffmuc_muc_west, ffmuc_uml_nord, ffmuc_uml_ost, ffmuc_uml_sued,
        ffmuc_uml_west
    - set new default_domain to ffmuc_welt
    - drop files for disabled domains
  - site.conf:
    - allow setting node location via map
    - implement usage if domain_director to let nodes ask for a domain it
      should switch to
  - Makefile:
    - setup Makefile to apply patches
      - add patches to fix BATMAN_V support (from ff chemnitz) for new
        segments


## v2019.0.2
  - drop ULA support and use public v6 addresses instead
  - drop IBSS in favor of 11s only mesh (and disable migration path where
    11s is disabled if ibss was disabled before)
  - enable configuration of private wifi in configmode

## v2019.0.1
  - Updated to Gluon v2018.2.1
    - Changes:
      - https://gluon.readthedocs.io/en/v2018.1.1/releases/v2017.1.html
      - https://gluon.readthedocs.io/en/v2018.1.1/releases/v2017.1.1.html
      - https://gluon.readthedocs.io/en/v2018.1.1/releases/v2017.1.2.html
      - https://gluon.readthedocs.io/en/v2018.1.1/releases/v2017.1.3.html
      - https://gluon.readthedocs.io/en/v2018.1.1/releases/v2017.1.4.html
      - https://gluon.readthedocs.io/en/v2018.1.1/releases/v2017.1.5.html
      - https://gluon.readthedocs.io/en/v2018.1.1/releases/v2017.1.6.html
      - https://gluon.readthedocs.io/en/v2018.1.1/releases/v2017.1.7.html
      - https://gluon.readthedocs.io/en/v2018.1.1/releases/v2017.1.8.html
      - https://gluon.readthedocs.io/en/v2018.1.1/releases/v2018.1.html
      - https://gluon.readthedocs.io/en/v2018.1.1/releases/v2018.1.1.html
      - https://gluon.readthedocs.io/en/v2018.2.1/releases/v2018.2.html
      - https://gluon.readthedocs.io/en/v2018.2.1/releases/v2018.2.1.html
  - site.conf
    - start using multidomain config
    - update translations (de,en) and added french
    - use GLUON_FEATURES
    - use GLUON_FEATURE web-wizard to have less packages
    - replace ULA for firmware.ffmuc.net by public v6 address
  - site.mk
    - remove tecff-respondd-watchdog
    - add ffho-autoupdater-wifi-fallback
    - use ebtables-limit-arp and ebtables-filter-multicast from gluon (instead of ffmuc version)
    - add ebtables-source-filter
    - prepare usage of vxlan for mesh
    - default to 11s for meshing (previous ibss)
      - if supported two different SSIDs will be broadcasted one for each
  - update translation for de, en and fr to match current situation
  - support for new devices
    - full list: https://gluon.readthedocs.io/en/v2018.2.1/#supported-devices-architectures

## v2018.1
 - Added sign keys of awlnx, krombel, lukesix to let them sign future releases

## v2018.0

 - Updated to Gluon v2016.2.7-3-g35c9f9ae
   - ar71xx: fix MAC addresses on TP-Link TL-WR1043ND v4
   - modules: update url to chaos calmer git repository after upstream move
   - ar71xx: sysupgrade: improve CPE/WBS 210/510 validation

 - Makefile
   - Enabled firmware with ath10k WLAN driver

## v2017.1

 - Updated to Gluon v2016.2.7
   - Changes:
     - https://gluon.readthedocs.io/en/v2016.2.7/releases/v2016.2.7.html

## v2017.0

 - Updated to Gluon v2016.2.6 (upstream)
   - Changes:
     - https://gluon.readthedocs.io/en/v2016.2.7/releases/v2016.1.6.html
     - https://gluon.readthedocs.io/en/v2016.2.7/releases/v2016.2.html
     - https://gluon.readthedocs.io/en/v2016.2.7/releases/v2016.2.1.html
     - https://gluon.readthedocs.io/en/v2016.2.7/releases/v2016.2.2.html
     - https://gluon.readthedocs.io/en/v2016.2.7/releases/v2016.2.3.html
     - https://gluon.readthedocs.io/en/v2016.2.7/releases/v2016.2.4.html
     - https://gluon.readthedocs.io/en/v2016.2.7/releases/v2016.2.5.html
     - https://gluon.readthedocs.io/en/v2016.2.7/releases/v2016.2.6.html
 - site.mk
   - added GLUON_REGION = eu setting

## v2016.0
 - Updated to Gluon v2016.1.5 (ffmuc fork)
   - Changes:
     - https://gluon.readthedocs.org/en/v2016.1/releases/v2016.1.html
     - https://gluon.readthedocs.org/en/v2016.1.1/releases/v2016.1.1.html
     - https://gluon.readthedocs.org/en/v2016.1.2/releases/v2016.1.2.html
     - https://gluon.readthedocs.org/en/v2016.1.3/releases/v2016.1.3.html
     - https://gluon.readthedocs.org/en/v2016.1.4/releases/v2016.1.4.html
     - https://gluon.readthedocs.org/en/v2016.1.5/releases/v2016.1.5.html
     - mesh_no_rebroadcast for mesh-on-wan (8b66da95f1887fc6068a6e9d6b6494c2ff4d2fb4)
     - preserve wifi channels feature (76a77902e3624167e81ca6e200519468bb66d5f7)
     - new package tecff-ath9k-broken-wifi-workaround (freifunkmuc/gluon-packages)
     - added fix for autoupdater (8f5a7c90019085dd8f02f96ab0e7a905f82e1be0)
 - site.conf
   - changed MTU size to 1280
   - due to the decreased MTU fastd can now support IPv6
 - site.mk
   - added USB support for various devices

## v2015.7
 * New stable unified firmware for all segments with site-select feature
 * Raised required signatures for stable release to 3

## v2015.6.2
 * Bugfix build for welcome version

## v2015.6.1
 * Added support of site selection in config mode
 * Switch autoupdater URL back to main firmware repo path

## v2015.6
 - Updated to Gluon 2015.1.2
   - Changes: https://gluon.readthedocs.org/en/v2015.1.2/releases/v2015.1.2.html

## v2015.5
 - Updated to Gluon 2015.1.1
   - Fixes some problems with mesh on LAN setups
 - x86 images now support two network interfaces, eth0 for LAN and eth1 for WAN
 - Mesh on WAN is disabled by default
 - VPN connection limit was decreased from 2 to 1 to divide the broadcast traffic
   into half and take unnecessary load from overloaded gateways

## v2015.4 [never released]
 - Updated to Gluon 2015.1
   - More supported architectures and router models are available, including x86
 - Setup Mode
   - A new wifi configuration page is available to disable client and mesh
     networks on 2.4 & 5GHz indiviually
   - Mesh on WAN can now be configured and is enabled by default
   - Internationalization for German and English is available and will
     be autodetected depending on the browser setting

## v2015.3
 - Add 4 new gateways as placeholders (not all are and will be active immediately)
 - Integrated no_rebroadcast fix on mesh-vpn from Gluon Upstream
 - Added another key for stable version signing

## v2015.2
 - Updated to new upstream gluon: 52698e62bac2ec0f8764b12cf437040528e77efb
 - Switched to batman-adv compat version 15
 - Changed channel to 6 with HT20 on 2.4GHz
 - Added FFMuc custom gluon packages with ebtables rules:
   - mcast-drop-non-site to prohibit arp traffic except 10.8.0.0/16
   - mcast-drop-arp to drop arp traffic from/to 0.0.0.0
   - mcast-allow-cjdns to allow cjdns multicast traffic
 - Use new gateways with DNS names
 - Changed default download/upload traffic shaping to 12.000/1.200 kbit/s
 - Removed keyformular note on end of luci configuration, as we're now
   blacklisting keys instead of whitelisting
 - Added information about liquid feedback on end of luci configuration
 - Use improved version naming scheme for autoupdater compatibility with
   intermediate versions
 - Use internal NTP server 0.ntp.ffmuc.net
 - Connections from nodes to gateways only over IPv4 for now (MTU issues)

## v2015.1
 - Updated to Gluon 2014.4 release
 - Autoupdater
   - Now enabled per default
   - Also fetch firmware from build.freifunk-muenchen.de
   - Require two signatures instead of one for stable autoupdate

## snapshot~20141119
 - fixed ipv4-prefix to /16 netmask
 - changed gateways ips to domain-names
 - changed `msg_pub_key` to automate entering the node-data to our key-form
 - changed mesh-SSID from 02:0E:8E:1E:61:17 to mesh.ffm
 - added `ntp_servers` '2.ntp.services.ffm','3.ntp.services.ffm','4.ntp.services.ffm'
 - changed `site_code` back to ffmuc (instead of ffm)
 - changed `hostname_prefix` to NULL
 - changed `mesh_ssid` to mesh.ffmuc
 - added public key from fpletz

## 0.6~stable20141018
 - changed ip address for gw02

## 0.6~stable20141011
 - gw04 hinzugefügt
 - Text "Knoten hinzufügen" geändert
 - Autoupdater auf "stable" als Standart-Wert gesetzt

## 0.6~exp20141004
 - Autoupdater hinzugefügt

## 0.6~exp20140926
 - Bugfixes
 - gw02 hinzugefügt

## 0.6~exp20140907
 - initiale Version
