# Change a node from the normal FFMUC firmware to Parker

You can change a node from the normal FFMUC firmware (branch `stable`,
`testing` or `experimental`) to the Parker firmware with one command
block. You do not need config mode.

## What the node keeps

| Setting | Result |
| --- | --- |
| Hostname, location, contact, SSH keys, password | Kept by sysupgrade. |
| Mesh VPN on or off, bandwidth limit | Kept by Gluon. |
| Mesh on WAN or LAN, private Wi-Fi, outdoor mode | Kept by Gluon. |
| Domain (for example `ffmuc_muc_cty`) | Each old domain is an alias of a Parker domain. |
| WireGuard key | The package `ffmuc-parker-migrate` moves it to Parker. The node keeps its public key. |
| Autoupdater branch | Set to `parker` (`update_channel` in `site.conf`). |

## Procedure

1. Connect to the node with SSH.
2. Paste this block. It adds the `parker` branch to the autoupdater and
   starts the upgrade:

   ```sh
   uci -q delete autoupdater.parker
   uci set autoupdater.parker=branch
   uci set autoupdater.parker.name=parker
   uci set autoupdater.parker.good_signatures=1
   uci add_list autoupdater.parker.mirror='http://firmware.ffmuc.net/parker/sysupgrade'
   uci add_list autoupdater.parker.mirror='http://5.1.66.255/parker/sysupgrade'
   uci add_list autoupdater.parker.mirror='http://185.150.99.255/parker/sysupgrade'
   uci add_list autoupdater.parker.mirror='http://[2001:678:e68:f000::]/parker/sysupgrade'
   uci add_list autoupdater.parker.mirror='http://[2001:678:ed0:f000::]/parker/sysupgrade'
   uci add_list autoupdater.parker.pubkey=6dcfc670a4150e16962c1852066669d9b337f168d0f6a863ed930968c2f047eb
   uci add_list autoupdater.parker.pubkey=5700c7a266d80aa1c6c33f29835a7b200bdd500e88ee86c0a63e24a0023364f6
   uci add_list autoupdater.parker.pubkey=216a34d34a15688e127d8d90e6c57587aa8c682b0648322f68338487657fd5ff
   uci add_list autoupdater.parker.pubkey=2a74ed02120a7d48bb2dc9be988b3480ed99844054b3d7f3e5d3df27d19d814b
   uci add_list autoupdater.parker.pubkey=56c4201f6ce2994678b0142e19099dd28d6ed17775d35ca9a7f12d9235890ffc
   uci add_list autoupdater.parker.pubkey=3cc6dc6d0d7499d4d17cacad5f16336634e0b26700807f29cc241eaabbde481f
   uci add_list autoupdater.parker.pubkey=e7a50df4bc8875113eaf75dff5204e8753a9189baeed40c6db0509398a428820
   uci add_list autoupdater.parker.pubkey=50bafd8216cab2ee1c11c215b528dd7c6396f3edfdab689c70ca04a9f284b931
   uci add_list autoupdater.parker.pubkey=cc7e3a6a4788d4246075923b298634f14a4fd179020ef6369fb74d601f55cc84
   uci add_list autoupdater.parker.pubkey=18fecc717a237ea5702fb97fa4689f9307d0267e3ee8f09377dbed99397b77b9
   uci commit autoupdater
   autoupdater -b parker -f --force-version
   ```

3. Wait. The node downloads the image, checks the signatures, writes
   the image and reboots.

The values in the block come from `autoupdater.branches.parker` in
`site.conf`. If you change that section, change this block too.

`--force-version` is necessary because a Parker version number can be
lower than the version number of the normal firmware.

## Go back to the normal firmware

The Parker firmware knows the `stable` branch:

```sh
autoupdater -b stable -f --force-version
```

In this direction, the normal firmware makes a new WireGuard key.
