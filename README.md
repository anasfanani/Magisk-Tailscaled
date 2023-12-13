# Magisk Tailscaled

This repository contains a Magisk module for running Tailscale on rooted Android devices.

## Requirements

- An Android device with Magisk root installed.
- Currently only support for `arm` or `arm64` architecture.

## Installation

1. Download the latest zip file from the [Releases](https://github.com/anasfanani/Magisk-Tailscaled/releases/latest) page.
2. Install the downloaded zip file using Magisk.
3. Reboot your phone.

After installation, the Tailscale daemon (`tailscaled`) will run automatically on boot.

## Usage

This module runs `tailscaled` with the `--tun=userspace-networking` option, which uses a userspace network stack instead of the kernel's network stack. This can be useful on devices where the kernel's network stack is not compatible with Tailscale.

The state file for `tailscaled` is stored at `/data/local/tmp/tailscaled.state`, and the log output is written to `/data/local/tmp/tailscaled.log`.

## Instructions

1. Reboot your device.
2. Open the Terminal.
3. Run 'su' to gain root access.
4. Run 'tailscale login' to login to your Tailscale account.
5. Open the URL in a browser to authorize your device.
6. Run 'tailscale status' to check the Tailscale connection.

## Troubleshooting

1. Check logs in `/data/local/tmp/tailscaled.log`.

## Notice

- Tailscale has some bugs.
- To login to Tailscale, you need to go to the tmp directory.
- You can use these commands:
- `su && cd /data/local/tmp/ && tailscale login`

## Links

- [Tailscale Userspace Networking](https://tailscale.com/kb/1112/userspace-networking/)
- [Termux Issue #10166](https://github.com/termux/termux-packages/issues/10166)
- [Tailscale Static Packages](https://pkgs.tailscale.com/stable/#static)

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.