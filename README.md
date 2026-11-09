# ananicy-rules-custom

Packages your own ananicy rules as an Arch package. Everything inside
`ananicy.d/` gets installed into `/etc/ananicy.d/` with the same layout.

```
ananicy.d/
├── 00-types.types                 -> /etc/ananicy.d/00-types.types
└── 00-default/
    ├── browsers/firefox.rules     -> /etc/ananicy.d/00-default/browsers/firefox.rules
    └── games/steam.rules          -> /etc/ananicy.d/00-default/games/steam.rules
```

The example rules are only placeholders. Replace them with your own.

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

- `/etc/ananicy.d/` is created if it doesn't exist. The package owns only the
  files it ships, so other packages' rules in the same folder are left alone.
- Every shipped file is listed in `backup=()` automatically. If you edit a
  file in `/etc/ananicy.d/` by hand, pacman keeps your version on upgrade and
  writes the new one as `.pacnew`.
- Files are installed `root:root`, mode `644`; directories `755`.
- If a file path clashes with one shipped by another package (for example
  `ananicy-cpp` or `cachyos-ananicy-rules`), pacman refuses to install it.
  Rename the file or put it in its own subfolder.
- Clean uninstall: `sudo pacman -R ananicy-rules-custom`
