[![anasfanani - Magisk-Tailscaled](https://img.shields.io/static/v1?label=anasfanani&message=Magisk-Tailscaled&color=blue&logo=github)](https://github.com/anasfanani/Magisk-Tailscaled "Go to GitHub repo")
[![Check and Update Tailscale Binary](https://github.com/anasfanani/Magisk-Tailscaled/actions/workflows/update.yml/badge.svg)](https://github.com/anasfanani/Magisk-Tailscaled/actions/workflows/update.yml)
[![Github All Releases](https://img.shields.io/github/downloads/anasfanani/Magisk-Tailscaled/total.svg)]()
[![GitHub release](https://img.shields.io/github/release/anasfanani/Magisk-Tailscaled?include_prereleases=&sort=semver&color=blue)](https://github.com/anasfanani/Magisk-Tailscaled/releases/)
[![issues - Magisk-Tailscaled](https://img.shields.io/github/issues/anasfanani/Magisk-Tailscaled)](https://github.com/anasfanani/Magisk-Tailscaled/issues)

# Magisk Tailscaled

This repository contains a Magisk module for running Tailscale on rooted Android devices.

## What is Tailscale?

Tailscale is a networking tool that allows you to connect each of your devices as if they were on the same VPN. For example, an Android phone connected to the Tailscale network can communicate with any other device connected to Tailscale. You can install it on your PC and Android device and then connect them using the Tailscale IP. For more information, check out [How Tailscale Works](https://tailscale.com/blog/how-tailscale-works).

## Difference between this Magisk module and the Tailscale app on Play Store

The [Tailscale app](https://play.google.com/store/apps/details?id=com.tailscale.ipn) on the Play Store runs with Android's VPN, which means you can't use Tailscale while another VPN is active. This Magisk module, on the other hand, allows you to use both an Android VPN and Tailscale at the same time.

## Requirements

- An Android device with Magisk root installed.
- Currently only support for `arm` or `arm64` architecture.

## Installation

1. Download the latest zip file from the [Releases](https://github.com/anasfanani/Magisk-Tailscaled/releases/latest) page.
2. Install the downloaded zip file using Magisk.
3. Reboot your phone.

After installation, the Tailscale daemon (`tailscaled`) will run automatically on boot.

## Usage

This module runs `tailscaled` with the following command:

```bash
tailscaled -tun=userspace-networking -statedir=/data/local/tmp/ -state=/data/local/tmp/tailscaled.state -socket=/data/local/tmp/tailscaled.sock -port=41641
```
This command uses a userspace network stack instead of the kernel's network stack, which can be useful on devices where the kernel's network stack is not compatible with Tailscale. The state file for tailscaled is stored at `/data/local/tmp/tailscaled.state`, and the log output is written to `/data/local/tmp/tailscaled.log`.

## Instructions

1. Open the Terminal.
2. Run 'su' to gain root access.
3. Run 'tailscale login' to login to your Tailscale account.
4. Open the URL in a browser to authorize your device.
5. Run 'tailscale status' to check the Tailscale connection.
6. Alternatively, you can open the [Tailscale Admin Dashboard](https://login.tailscale.com/admin/machines) to manage your devices.


GitHub Copilot: You can add the following section to your README.md file:

## Example of Using Tailscale

You can use Tailscale to connect SSH from Termux on Android to a Windows PC. Here's how:

### On your Android device:

1. Set up SSHD:

```bash
apt update && apt upgrade
apt install openssh
passwd
```

Enter your password when prompted, for example, `123`.

2. Get your IP with the command `tailscale ip` or check your IP in the [Tailscale Admin Dashboard](https://login.tailscale.com/admin/machines).

### On your Windows PC:

1. Open the terminal.
2. SSH to your Android IP:

```bash
ssh [randomuser]@[android ip tailscale] -p 8022
```

For example:

```bash
ssh user@100.95.95.95 -p 8022
```

## Avalilable command

```
USAGE
  tailscale [flags] <subcommand> [command flags]

For help on subcommands, add --help after: "tailscale status --help".

This CLI is still under active development. Commands and flags will
change in the future.

SUBCOMMANDS
  up         Connect to Tailscale, logging in if needed
  down       Disconnect from Tailscale
  set        Change specified preferences
  login      Log in to a Tailscale account
  logout     Disconnect from Tailscale and expire current node key
  switch     Switches to a different Tailscale account
  configure  [ALPHA] Configure the host to enable more Tailscale features
  netcheck   Print an analysis of local network conditions
  ip         Show Tailscale IP addresses
  status     Show state of tailscaled and its connections
  ping       Ping a host at the Tailscale layer, see how it routed
  nc         Connect to a port on a host, connected to stdin/stdout
  ssh        SSH to a Tailscale machine
  funnel     Turn on/off Funnel service
  serve      Serve content and local servers
  version    Print Tailscale version
  web        Run a web server for controlling Tailscale
  file       Send or receive files
  bugreport  Print a shareable identifier to help diagnose issues
  cert       Get TLS certs
  lock       Manage tailnet lock
  licenses   Get open source license information
  exit-node

FLAGS
  --socket string
        path to tailscaled socket (default /var/run/tailscale/tailscaled.sock)
```

For more details about CLI commands, check out the [Tailscale CLI documentation](https://tailscale.com/kb/1080/cli#using-the-cli).

## Troubleshooting

Tailscale has some known issues. You can check them out [here](https://github.com/tailscale/tailscale/issues?q=no+safe+place+found+to+store+log+state).

In order to execute any Tailscale command on the terminal, you must navigate to the directory `/data/local/tmp/` and then execute the Tailscale command. For example, `cd /data/local/tmp/` then `tailscale login`, or `tailscale status`.

If you encounter any problems, take a look at the `service.sh` file. You can modify the commands that are not necessary. If you make some modifications to the commands and they work, please open an issue and make a report.

Currently, this module does not support KernelSU as the author has not used it. Therefore, the author cannot create a module for KernelSU. 

If you encounter any issues, you can check the logs at `/data/local/tmp/tailscaled.log`.

For more information, check out the links below:

## Links

- [Tailscale Userspace Networking](https://tailscale.com/kb/1112/userspace-networking/)
- [Termux Issue #10166](https://github.com/termux/termux-packages/issues/10166)
- [Tailscale Static Packages](https://pkgs.tailscale.com/stable/#static)
- [Tailscale Knowledge Base](https://tailscale.com/kb)

## Disclaimer

This module is not affiliated with the official Tailscale. It is a third-party implementation and the author is not responsible for any damage to your device that may occur from its use. Use at your own risk.

## License

Released under [BSD 3-Clause License](/LICENSE).