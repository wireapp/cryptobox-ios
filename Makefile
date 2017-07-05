SHELL   := /usr/bin/env bash
VERSION := 1.0.0

TARGETS_ios := armv7-apple-ios \
           i386-apple-ios \
           aarch64-apple-ios \
           x86_64-apple-ios
TARGETS_macos := x86_64-apple-darwin

# pkg-config is invoked by libsodium-sys
# cf. https://github.com/alexcrichton/pkg-config-rs/blob/master/src/lib.rs#L12
export PKG_CONFIG_ALLOW_CROSS=1

.PHONY: all
all: dist

.PHONY: distclean
distclean:
	rm -rf build
	rm -rf dist

dist-libs-%: cryptobox-%
	mkdir -p dist/lib/$*/
	mkdir -p dist/include
	cp build/lib/$*/libsodium.a dist/lib/$*
	cp -r build/include/* dist/include/
	lipo -create $(foreach tgt,$(TARGETS_$(*)),"build/lib/$*/libcryptobox-$(tgt).a") \
		-output "dist/lib/$*/libcryptobox.a"

dist/cryptobox-$(VERSION).tar.gz: dist-libs-ios dist-libs-macos
	tar -C dist \
		-czf dist/cryptobox-$(VERSION).tar.gz \
		lib include

.PHONY: dist-tar
dist-tar: dist/cryptobox-$(VERSION).tar.gz

.PHONY: dist
dist: dist-tar

#############################################################################
# cryptobox

include mk/cryptobox-src.mk

cryptobox-%: build/lib/%/libcryptobox.a build/include/%/cbox.h
	echo $*

build/lib/%/libcryptobox.a: libsodium-% | $(CRYPTOBOX_SRC)
	cd $(CRYPTOBOX_SRC) && \
	sed -i.bak s/crate\-type.*/crate\-type\ =\ \[\"staticlib\"\]/g Cargo.toml && \
	$(foreach tgt,$(TARGETS_$(*)),cargo rustc --lib --release --target=$(tgt);)
	mkdir -p build/lib
	$(foreach tgt,$(TARGETS_$(*)),cp $(CRYPTOBOX_SRC)/target/$(tgt)/release/libcryptobox.a build/lib/$*/libcryptobox-$(tgt).a;)

build/include/%/cbox.h: | $(CRYPTOBOX_SRC)
	mkdir -p build/include/$*
	cp $(CRYPTOBOX_SRC)/src/cbox.h build/include/$*

#############################################################################
# libsodium

include mk/libsodium-src.mk

libsodium-%: build/lib/%/libsodium.a build/include/%/sodium.h
	echo $*

build/lib/%/libsodium.a: | $(LIBSODIUM_SRC)
	cp mk/$*-full.sh $(LIBSODIUM_SRC)/dist-build && \
		chmod +x $(LIBSODIUM_SRC)/dist-build/$*-full.sh && \
		cd $(LIBSODIUM_SRC) && \
		dist-build/$*-full.sh
	mkdir -p build/lib/$*
	cp $(LIBSODIUM_SRC)/libsodium-$*/libsodium.a build/lib/$*/libsodium.a


build/include/%/sodium.h: build/lib/%/libsodium.a
	mkdir -p build/include/$*
	cp $(LIBSODIUM_SRC)/libsodium-$*/include/sodium.h build/include/$*/sodium.h
	cp -r $(LIBSODIUM_SRC)/libsodium-$*/include/sodium build/include/$*/sodium
