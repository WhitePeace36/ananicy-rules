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

It needs [ananicy-cpp](https://github.com/WhitePeace36/ananicy-cpp) 1.4.0 or newer, which loads
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
