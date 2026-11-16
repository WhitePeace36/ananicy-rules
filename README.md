# ananicy-rules-custom

Packages your own ananicy rules as an Arch package. Everything inside
`ananicy.d/` gets installed into `/usr/share/ananicy.d/` with the same layout.

```
ananicy.d/
├── ananicy.conf               -> /usr/share/ananicy.d/ananicy.conf
├── 99-types.types             -> /usr/share/ananicy.d/99-types.types
└── 99-rules/
    └── Game.rules             -> /usr/share/ananicy.d/99-rules/Game.rules
```

It needs [ananicy-cpp](https://github.com/WhitePeace36/ananicy-cpp) 1.4.0 or newer, which loads
`/usr/share/ananicy.d` first and `/etc/ananicy.d` after it. Lunar ships these rules as
`lunar-ananicy-rules`.

## Usage

```sh
# put/edit your files in ./ananicy.d/, then:
make install        # = makepkg -fi  (build + install)
# or
make build          # = makepkg -f   (just build the .pkg.tar.zst)

sudo systemctl restart ananicy-cpp   # load the new rules
```

After changing rules, bump `pkgrel` (or `pkgver`) in the PKGBUILD and run
`make install` again.

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
  packages (`lunar-ananicy-rules`, `cachyos-ananicy-rules` and its `-git`
  version, `ananicy-rules`, …), so pacman offers to replace them. CachyOS's
  rules would otherwise sit in `/etc/ananicy.d` and override these.
- Clean uninstall: `sudo pacman -R ananicy-rules-custom`
