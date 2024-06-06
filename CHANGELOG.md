## v1.66.4.0
- Update Tailscale binaries to v1.66.4
- MagicDNS with coredns
- Tailscale self build for android using sdk tools
- Compress and combine tailscale
- Delete `tailscaled` at system path as rarelly used
- New `tailscaled.service` feature
- Multiple start variant method
- Fix subnet routes access
- Fix ping
- Fix hevsocks for userspace-networking mode
- Code improvements
- Fix headscale dns
- Fix /etc/resolv.conf
- Fix run with VPN,Box For Root, Clash
- Fix any previous bug
- Split zip into multiple variant
- Maximum compression coredns file
- Update hev-socks5-tunnel
- Change settings.ini to settings.sh
- Delete unused script
- Recode old script

Everything should works fine !

Warn: small typo, if you want enable hevsocks, edit file settings.sh and change `hevsocks_conf` value with this `hevsocks_conf="${tailscale_dir}/tmp/hevsocks.yaml"`.

I have to rest 😓

**Full Changelog**: https://github.com/anasfanani/Magisk-Tailscaled/compare/v1.66.1.0...v1.66.4.0