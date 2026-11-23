# lunar-ananicy-rules

Lunar's ananicy-cpp rules, tuned for the Elara scheduler. The PKGBUILD here builds the
`lunar-ananicy-rules` package from this checkout (LunarOs builds the same package from the
release tags). Everything inside `ananicy.d/` gets installed into `/usr/share/ananicy.d/` with
the same layout.

```
ananicy.d/
├── ananicy.conf               -> /usr/share/ananicy.d/ananicy.conf
├── 99-types.types             -> /usr/share/ananicy.d/99-types.types
└── 99-rules/
    └── Game.rules             -> /usr/share/ananicy.d/99-rules/Game.rules
```

It needs [ananicy-cpp](https://github.com/WhitePeace36/ananicy-cpp-lunar) 1.4.0 or newer, which loads
`/usr/share/ananicy.d` first and `/etc/ananicy.d` after it.

## Usage

```sh
# put/edit your files in ./ananicy.d/, then:
make install        # = makepkg -fi  (build + install)
# or
make build          # = makepkg -f   (just build the .pkg.tar.zst)

sudo systemctl restart ananicy-cpp   # load the new rules
```

After changing rules, run `make install` again (it rebuilds and reinstalls the same version).
`pkgrel` stays at 1, so the package from the `[lunar]` repository is never older than a local
build: `pacman -Syu` switches to it once a newer release is published.

## Priority levels

| type        | nice | sched  | IO class     | for |
|-------------|------|--------|--------------|-----|
| `LC`        | -12  | normal | best-effort  | only audio servers (pipewire, pipewire-pulse, pulseaudio), the display server/compositor (kwin, Xwayland, Xorg) and wineserver |
| `Game`      | -5   | normal | follows nice | games and what runs them (Steam's `reaper`, gamescope, Proton), wireplumber |
| `Normal`    | 0    | normal | follows nice | everything interactive (browsers, terminals, the desktop shell); resets what was inherited |
| `Heavy_CPU` | 10   | —      | follows nice | heavy but interactive programs (IDEs, blender, VMs) |
| `Service`   | 10   | normal | follows nice | daemons |
| `BG_CPU`    | 15   | batch  | follows nice | compilers, build tools, encoders, compressors |
| `Launcher`  | 16   | normal | idle         | game launchers: only used briefly, busy in the background otherwise |
| `BG_CPUIO`  | 16   | idle   | idle         | greeters and display manager daemons (not needed after login), sync, backup, indexing |
| `OOM_KILL` / `OOM_NO_KILL` | | |             | only set `oom_score_adj` |

The old type names `Doc-View`, `Chat`, `Image-View`, `Player-Audio`, `Player-Video`, `IN_DIFF`
and `LowLatency_RT` no longer exist. ananicy skips a rule whose type is unknown, so a rule of
your own in `/etc/ananicy.d` that still uses one of them needs a current type (`Normal` has the
values they had).

Things to keep in mind when adding rules:

- Children inherit nice, scheduling class and IO class. A rule on a process that starts others
  (a display manager, a session manager, a launcher, a wrapper like `bwrap`) applies to everything
  below it that has no rule of its own. That is why the per-session helpers of the display
  managers (`sddm-helper`, `gdm-session-worker`, `lightdm --session-child`, ...) are `Normal`
  while the display managers themselves are `BG_CPUIO`.
- The name is the basename of `argv[0]`. For a script that is the interpreter (`bash`,
  `python3`), so a rule for the script's name never matches: use `cmdline_contains` on the
  interpreter instead, e.g. `{ "name": "python3", "cmdline_contains": "bin/lutris", "type": "Launcher" }`.
  Never add a rule for a shell or a language runtime itself: it would match every script.

## Notes

- Your own changes go to `/etc/ananicy.d/`, never into `/usr/share/ananicy.d/`:
  a rule, type or cgroup defined there replaces the packaged one with the same
  name, `{"name": "steam"}` alone switches a packaged rule off, and keys in
  `/etc/ananicy.d/ananicy.conf` win over the packaged `ananicy.conf`.
  [AnanicyConfigurator](https://github.com/WhitePeace36/AnanicyConfigurator)
  1.2.0 or newer does this for you.
- Updates replace `/usr/share/ananicy.d/` completely and never touch
  `/etc/ananicy.d/`, so there are no `.pacnew` files to merge.
- Files are installed `root:root`, mode `644`; directories `755`.
- If a file path clashes with one shipped by another package (for example
  another rules package in `/usr/share/ananicy.d`), pacman refuses to install
  it. Rename the file or put it in its own subfolder.
- Only one rule set at a time: the package conflicts with the other rules
  packages (`cachyos-ananicy-rules` and its `-git` version, `ananicy-rules`, …)
  and with `ananicy-rules-custom`, its old name, so pacman offers to replace
  them. CachyOS's rules would otherwise sit in `/etc/ananicy.d` and override
  these.
- Clean uninstall: `sudo pacman -R lunar-ananicy-rules`
