# XFCE WM Silent Failure & Forensic Recovery

Site: https://swipswaps.github.io/xfce-wm-forensic-recovery/

## Root cause

`xfwm4` 4.20 tries to enable its compositor at startup. If a required X11
extension such as `RENDER` is not exported by the X server, it aborts
before its logging subsystem opens — so no log appears in `journalctl`,
`~/.xsession-errors`, or `XFWM4_LOG_FILE`.

## Fix

    setsid nohup xfwm4 --compositor=off >/tmp/xfwm4.log 2>&1 < /dev/null &
    xfconf-query -c xfwm4 -p /general/use_compositing -s false
    export GTK_CSD=0

Persist `GTK_CSD=0` in `~/.config/environment.d/10-gtk-csd.conf` as plain
`KEY=VALUE` — `environment.d` does not accept `export`.

## Scripts (also served at /scripts/<name>.sh)

| Script | Purpose |
|---|---|
| `xfce-wm-diagnose.sh` | read-only diagnostics |
| `xfce-wm-fix.sh` | reversible fix |
| `monitor.sh` | one-shot health snapshot |
| `recover.sh` | tibet-snap compare + rollback plan |
| `configsnap-baseline.sh` | one-shot configsnap pre/post/report |
| `tibet-snap-baseline.sh` | one-shot sealed snapshot + verify + rollback plan |
| `forensic-baseline.sh` | runs all of the above into one `.tar.gz` bundle |

## Forensic stack

- statedrift — tamper-evident host snapshots, diff, evidence export
- configsnap — Fedora-native state record/compare (phases with `post` diff automatically)
- tibet-snap / tibet-wayback — cryptographic snapshots, Python rollback-plan API
- timeshift — optional full-system restore

## References

- xfwm4 upstream: <https://gitlab.xfce.org/xfce/xfwm4>
- environment.d(5): <https://man7.org/linux/man-pages/man5/environment.d.5.html>
- configsnap man page: <https://man.sourcentral.org/f40/1+configsnap>
- tibet-snap on PyPI: <https://pypi.org/project/tibet-snap/>
- GitHub Pages API: <https://docs.github.com/en/rest/pages/pages>
- gh api nested fields: <https://cli.github.com/manual/gh_api>
