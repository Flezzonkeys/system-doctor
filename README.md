<p align="center"><img src="data/system-doctor.svg" width="112" alt="System Doctor icon"></p>

<h1 align="center">System Doctor</h1>

A daily health check for Arch-based Linux systems (Arch, CachyOS, EndeavourOS, Manjaro and others),
with a clear dashboard and desktop notifications when something goes wrong.

System Doctor runs quietly in the background 10 minutes after boot and once a day. It only
notifies you when a problem is **new or got worse**, so you are not bothered by the same message every day.

![Dashboard](screenshots/dashboard.png)

<details>
<summary>Light theme</summary>

![Dashboard in the light theme](screenshots/dashboard-light.png)
</details>

## Highlights

- **Dashboard** with one card per area. Click a card to see everything about it.
- **Dark and light theme.** Dark is the default, switch with one click (or `Ctrl+T`). The choice is remembered.
- **Mark warnings as seen.** Crashes, failed services and log errors you already know about can be
  hidden with *Mark as seen*. The warning comes back only when something **new** happens.
  *Show again* brings them back.
- **Notifications only for news.** You get a desktop notification when a problem is new or got worse,
  not every day for the same thing.

## What it checks

| Section | What you see | Warns when |
|---|---|---|
| **System info** | OS, kernel, desktop, CPU, GPUs with VRAM, Mesa, RAM modules, mainboard and BIOS, uptime, packages | never (information only) |
| **Usage** | RAM, swap and CPU usage, the programs using the most memory and CPU | RAM almost full, swap mostly used |
| **Drives** | SMART health of every NVMe/SATA drive: wear, temperature, power-on hours, TB written, unsafe shutdowns | SMART failure, high wear, media errors, low spare blocks, hot drive |
| **Filesystems** | Btrfs error counters | read/write/corruption errors |
| **Disk space** | Fill level of every mounted filesystem | over 85 % (over 80 % for `/boot`) |
| **Temperatures** | CPU and CCDs, GPU edge/hotspot/VRAM, fan, power and clock, iGPU, RAM modules, Wi-Fi, USB | CPU, GPU or RAM running hot |
| **Services** | Failed system and user services | any failed service |
| **Crashes** | Programs that crashed in the last 24 hours (`coredumpctl`) | any crash |
| **System log** | Kernel log since boot: hardware errors (MCE), GPU hangs/resets, disk I/O errors, NVMe timeouts, out-of-memory kills | any of these |
| **Updates** | Pending updates and when the last full upgrade ran | no full upgrade for 3 weeks |
| **Maintenance** | `.pacnew` files, package cache size, orphaned packages | package cache over 20 GB |

## Install

Requirements: an Arch-based system with systemd. The installer checks for these packages and offers to
install what is missing: `python`, `python-pyqt6`, `smartmontools`, `lm_sensors`, `pacman-contrib`,
`dmidecode`, `libnotify`, `pciutils`. `btrfs-progs` is used when Btrfs filesystems exist.

```bash
git clone https://github.com/Flezzonkeys/system-doctor.git
cd system-doctor
sudo bash install.sh
```

The installer copies the programs to `/usr/local/bin`, enables a systemd timer and runs the first check.

## Usage

- **Window:** open *System Doctor* from the app menu. Click a card to see its details on the right.

  | Key | Action |
  |---|---|
  | `F5` | Run a new check |
  | `Ctrl+T` | Switch between dark and light theme |
  | `Ctrl+C` | Copy the selected section as text (handy for bug reports) |
  | `Ctrl+Q` | Quit |

- **Terminal:**

  ```text
  doctor        show the latest health report
  doctor now    run a new check and show the result
  doctor all    show the latest report with all details
  doctor clear  mark the current crash, log and service warnings as seen
  doctor gui    open the System Doctor window
  ```

## How it works

| Part | Purpose |
|---|---|
| `src/system-doctor` | The checker. Runs as root through `system-doctor.service`, writes `/var/lib/system-doctor/report.json` and sends notifications to logged-in users. |
| `src/system-doctor-gui` | The PyQt6 dashboard. Reads the report and can start a new check. |
| `src/doctor` | Terminal front end. |
| `data/system-doctor.timer` | Runs the check 10 minutes after boot and then once a day. |
| `data/50-system-doctor.rules` | polkit rule that lets the logged-in local user start the check without a password. Nothing else is allowed. |

Your theme choice and the warnings you marked as seen are stored per user in
`~/.config/system-doctor/`.

System Doctor only **reads** the state of your system. It never changes, repairs or deletes anything.
Where a fix is simple, the details show the command to run yourself (for example `sudo paccache -rk1`).

## Uninstall

```bash
sudo bash uninstall.sh
```

## License

MIT, see [LICENSE](LICENSE).
