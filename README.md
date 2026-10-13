# tmog-rapl-gate

Lets [Task Manager TMOG](https://www.tmog.org/) show CPU power on Linux **without** permanently re-opening the RAPL energy counters.

Since kernel 5.10 (CVE-2020-8694, "PLATYPUS"), `/sys/class/powercap/*/energy_uj` is readable only by root, so TMOG's Power view shows *Access denied* for normal users. Running TMOG under sudo loses your settings and Pro licence, and a udev rule exposes the counters at every boot whether TMOG is open or not.

This add-on opens the counters only while TMOG is running:

1. `dpkg-divert` moves `/usr/bin/tmog-task-manager` to `/usr/bin/tmog-task-manager.real` and installs a small wrapper in its place. Menu, terminal, Summon and autostart launches all go through it, and TMOG upgrades land in `.real` automatically.
2. The wrapper runs `pkexec /usr/libexec/tmog-rapl-gate/rapl-gate open` (`chmod o+r` on each `energy_uj`), starts the real binary as you, and waits.
3. When TMOG exits, the wrapper runs `rapl-gate close`. The helper relocks only when no other launcher holds a lease and no process is running the real binary, so the single-instance handoff and other users' sessions are safe.

A polkit action (`allow_active=yes`, `allow_inactive=no`, `allow_any=no`) lets the local desktop session do this with no password prompt. SSH and inactive sessions are refused, and TMOG still starts normally. Every open and relock is logged: `journalctl -t tmog-rapl-gate`.

No TMOG files are shipped or modified.

## Install

Requires the TMOG `.deb` (`taskmanagerog`) and Debian 12+, Ubuntu 23.04+, or Linux Mint 22+.

```
sudo apt install ./tmog-rapl-gate_1.0.0_all.deb
```

Download the `.deb` from [Releases](../../releases), or build it with `./build.sh`.

## Check it

```
ls -l /sys/class/powercap/*/energy_uj   # -r--------  (TMOG closed)
tmog-task-manager &
ls -l /sys/class/powercap/*/energy_uj   # -r-----r--  (TMOG running)
```

## Remove

```
sudo apt remove tmog-rapl-gate
```

This removes the diversion, restores the original binary, and relocks the counters.

## Tested

- Package lifecycle (install, TMOG reinstall, remove) on Debian 12, Debian 13 and Ubuntu 24.04
- Live on Linux Mint 22.3 with an Intel i9-11950H

## License

MIT
