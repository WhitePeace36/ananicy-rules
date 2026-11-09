.PHONY: all build install srcinfo clean

all: build

# Build the package (.pkg.tar.zst) in this folder
build:
	makepkg -f

# Build and install it with pacman
install:
	makepkg -fi

# Regenerate .SRCINFO (needed if you publish to the AUR)
srcinfo:
	makepkg --printsrcinfo > .SRCINFO

clean:
	rm -rf pkg src *.pkg.tar.*
