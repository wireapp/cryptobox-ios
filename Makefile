SHELL   := /usr/bin/env bash
VERSION := 1.2.0

TARGETS := x86_64-apple-ios \
		   aarch64-apple-ios-sim

# pkg-config is invoked by libsodium-sys
# cf. https://github.com/alexcrichton/pkg-config-rs/blob/master/src/lib.rs#L12
export PKG_CONFIG_ALLOW_CROSS=1

.PHONY: all
all: dist

.PHONY: distclean
distclean:
	rm -rf build
	rm -rf dist

.PHONY: dist-libs
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

.PHONY: dist-tar
dist-tar: dist/cryptobox-ios-$(VERSION).tar.gz

.PHONY: dist
dist: dist-tar

#############################################################################
# cryptobox

include mk/cryptobox-src.mk

.PHONY: cryptobox
cryptobox: build/lib/libcryptobox.a build/include/cbox.h

build/lib/libcryptobox.a: libsodium | $(CRYPTOBOX_SRC)
	cd $(CRYPTOBOX_SRC) && \
	sed -i.bak s/crate\-type.*/crate\-type\ =\ \[\"staticlib\"\]/g Cargo.toml && \
	$(foreach tgt,$(TARGETS),cargo rustc --lib --release --target=$(tgt);)
	mkdir -p build/lib
	$(foreach tgt,$(TARGETS),cp $(CRYPTOBOX_SRC)/target/$(tgt)/release/libcryptobox.a build/lib/libcryptobox-$(tgt).a;)

build/include/cbox.h: | $(CRYPTOBOX_SRC)
	mkdir -p build/include
	cp $(CRYPTOBOX_SRC)/src/cbox.h build/include/

#############################################################################
# libsodium

include mk/libsodium-src.mk

.PHONY: libsodium
libsodium: build/lib/libsodium.a build/include/sodium.h

build/lib/libsodium.a: | $(LIBSODIUM_SRC)
	cp mk/ios-full.sh $(LIBSODIUM_SRC)/dist-build && \
		chmod +x $(LIBSODIUM_SRC)/dist-build/ios-full.sh && \
		cd $(LIBSODIUM_SRC) && \
		dist-build/ios-full.sh
	mkdir -p build/lib
	cp $(LIBSODIUM_SRC)/libsodium-ios/libsodium.a build/lib/libsodium.a

build/include/sodium.h: build/lib/libsodium.a
	mkdir -p build/include
	cp $(LIBSODIUM_SRC)/libsodium-ios/include/sodium.h build/include/sodium.h
	cp -r $(LIBSODIUM_SRC)/libsodium-ios/include/sodium build/include/sodium
