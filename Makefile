SHELL   := /usr/bin/env bash
VERSION := 0.1.0

TARGETS := armv7-apple-ios \
           armv7s-apple-ios \
           i386-apple-ios \
           aarch64-apple-ios \
           x86_64-apple-ios

NOOP  :=
SPACE := $(NOOP) $(NOOP)

# pkg-config is invoked by libsodium-sys
# cf. https://github.com/alexcrichton/pkg-config-rs/blob/master/src/lib.rs#L12
export PKG_CONFIG_ALLOW_CROSS=1

all: dist

distclean:
	rm -rf build
	rm -rf dist

dist-libs: cryptobox
	mkdir -p dist/lib
	mkdir -p dist/include
	cp build/lib/libsodium.a dist/lib/
	cp -r build/include/* dist/include/
	lipo -create $(foreach tgt,$(TARGETS),"build/lib/libcryptobox-$(tgt).a") \
		-output "dist/lib/libcryptobox.a"

dist/cryptobox-ios-$(VERSION).tar.gz: dist-libs
	tar -C dist \
		-czf dist/cryptobox-ios-$(VERSION).tar.gz \
		lib include

dist-tar: dist/cryptobox-ios-$(VERSION).tar.gz

dist: dist-tar

#############################################################################
# cryptobox

include mk/cryptobox-src.mk

build/lib/libcryptobox.a: libsodium build/src/$(CRYPTOBOX)
	cd build/src/$(CRYPTOBOX) && \
	sed -i.bak s/crate\-type.*/crate\-type\ =\ \[\"staticlib\"\]/g Cargo.toml && \
	$(foreach tgt,$(TARGETS),cargo rustc --lib --release --target=$(tgt) -- -L build/lib -l sodium;)
	mkdir -p build/lib
	$(foreach tgt,$(TARGETS),cp build/src/$(CRYPTOBOX)/target/$(tgt)/release/libcryptobox.a build/lib/libcryptobox-$(tgt).a;)

build/include/cbox.h: build/src/$(CRYPTOBOX)
	mkdir -p build/include
	cp build/src/$(CRYPTOBOX)/cbox.h build/include/

cryptobox: build/lib/libcryptobox.a build/include/cbox.h

#############################################################################
# libsodium

include mk/libsodium-src.mk

build/lib/libsodium.a: build/src/$(LIBSODIUM)
	cd build/src/$(LIBSODIUM) && dist-build/ios.sh
	mkdir -p build/lib
	cp build/src/$(LIBSODIUM)/libsodium-ios/libsodium.a build/lib/libsodium.a

build/include/sodium.h: build/lib/libsodium.a
	mkdir -p build/include
	cp build/src/$(LIBSODIUM)/libsodium-ios/include/sodium.h build/include/sodium.h
	cp -r build/src/$(LIBSODIUM)/libsodium-ios/include/sodium build/include/sodium

libsodium: build/lib/libsodium.a build/include/sodium.h
