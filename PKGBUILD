# Maintainer: Timon <timon2201@gmail.com>
#
# Installs everything under ./ananicy.d/ (next to this PKGBUILD) into
# /etc/ananicy.d/, keeping the exact same directory layout.
#
#   ./ananicy.d/00-types.types              -> /etc/ananicy.d/00-types.types
#   ./ananicy.d/00-default/games/foo.rules  -> /etc/ananicy.d/00-default/games/foo.rules

pkgname=ananicy-rules-custom
pkgver=1.0.0
pkgrel=1
pkgdesc="Custom rules, types and cgroups for ananicy / ananicy-cpp"
arch=('any')
url='https://github.com/WhitePeace36/ananicy-rules'
license=('GPL-2.0-only')
optdepends=('ananicy-cpp: daemon that applies these rules')

# Local folder holding the rules (relative to this PKGBUILD)
_rulesdir="ananicy.d"

# Mark every shipped file as a config file, so pacman keeps your local edits
# on upgrade (it writes .pacnew instead of overwriting). Generated from the
# folder contents, so you never have to maintain this list by hand.
backup=()
if [[ -d "$startdir/$_rulesdir" ]]; then
  while IFS= read -r -d '' _f; do
    backup+=("etc/ananicy.d/${_f#./}")
  done < <(cd "$startdir/$_rulesdir" && find . -type f -print0 | sort -z)
fi

package() {
  local src="$startdir/$_rulesdir"
  local dest="$pkgdir/etc/ananicy.d"

  if [[ ! -d "$src" ]]; then
    error "Rules folder not found: $src"
    return 1
  fi

  # Create /etc/ananicy.d itself (pacman creates it on install if missing)
  install -dm755 "$dest"

  cd "$src"

  # Recreate the directory tree (including empty directories)
  find . -mindepth 1 -type d -print0 | while IFS= read -r -d '' d; do
    install -dm755 "$dest/${d#./}"
  done

  # Copy every file with sane permissions and root ownership.
  # (install is used instead of `cp -a` so your user's uid/gid and
  #  odd permissions don't leak into the package.)
  find . -type f -print0 | while IFS= read -r -d '' f; do
    install -Dm644 "$f" "$dest/${f#./}"
  done

  # Preserve symlinks as symlinks, if you have any
  find . -type l -print0 | while IFS= read -r -d '' l; do
    install -dm755 "$dest/$(dirname "${l#./}")"
    cp -P --no-preserve=ownership "$l" "$dest/${l#./}"
  done
}
