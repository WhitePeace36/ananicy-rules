# Maintainer: Timon <timon2201@gmail.com>
#
# Builds lunar-ananicy-rules from this checkout: everything under ./ananicy.d/
# (next to this PKGBUILD) goes to /usr/share/ananicy.d/ with the same layout.
#
#   ./ananicy.d/99-types.types          -> /usr/share/ananicy.d/99-types.types
#   ./ananicy.d/99-rules/Game.rules     -> /usr/share/ananicy.d/99-rules/Game.rules
#
# Same package as LunarOs' lunar-ananicy-rules (built there from the release
# tag v$pkgver). pkgrel stays at 1 here, so the package from the [lunar]
# repository is never older than a local build and pacman -Syu switches to it.
#
# ananicy-cpp 1.4.0 or newer (github.com/WhitePeace36/ananicy-cpp-lunar) loads
# /usr/share/ananicy.d first and /etc/ananicy.d after it, so everything you
# change in /etc/ananicy.d (by hand or with AnanicyConfigurator) replaces the
# packaged definition and is never touched by an update of this package.

pkgname=lunar-ananicy-rules
pkgver=1.0.0
pkgrel=1
pkgdesc='Lunar - ananicy-cpp rules tuned for the Elara scheduler'
arch=('any')
url='https://github.com/WhitePeace36/ananicy-rules'
license=('GPL-2.0-only')
# older ananicy-cpp versions (and the original ananicy) only read /etc/ananicy.d
depends=('ananicy-cpp>=1.4.0')
# One rule set at a time: another one in /usr/share/ananicy.d clashes with these files, one in
# /etc/ananicy.d (cachyos-ananicy-rules) would override them. cachyos-ananicy-rules-git provides
# cachyos-ananicy-rules; the CachyOS repo's cachyos-ananicy-rules provides ananicy-rules-git.
# ananicy-rules-custom is this package's old name.
provides=('ananicy-rules')
conflicts=('ananicy-rules' 'ananicy-rules-git' 'ananicy-cpp-rules' 'cachyos-ananicy-rules'
           'ananicy-rules-custom')
replaces=('ananicy-rules-custom')

# Local folder holding the rules (relative to this PKGBUILD)
_rulesdir="ananicy.d"

package() {
  local src="$startdir/$_rulesdir"
  local dest="$pkgdir/usr/share/ananicy.d"

  if [[ ! -d "$src" ]]; then
    error "Rules folder not found: $src"
    return 1
  fi

  install -dm755 "$dest"

  cd "$src"

  # Recreate the directory tree (including empty directories)
  find . -mindepth 1 -type d -print0 | while IFS= read -r -d '' d; do
    install -dm755 "$dest/${d#./}"
  done

  # Copy every file with sane permissions and root ownership.
  # (install is used instead of `cp -a` so your user's uid/gid and
  #  odd permissions don't leak into the package.)
  find . -type f ! -path ./LICENSE -print0 | while IFS= read -r -d '' f; do
    install -Dm644 "$f" "$dest/${f#./}"
  done

  # Preserve symlinks as symlinks, if you have any
  find . -type l -print0 | while IFS= read -r -d '' l; do
    install -dm755 "$dest/$(dirname "${l#./}")"
    cp -P --no-preserve=ownership "$l" "$dest/${l#./}"
  done

  install -Dm644 LICENSE "$pkgdir/usr/share/licenses/$pkgname/LICENSE"
}
