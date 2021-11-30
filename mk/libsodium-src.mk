LIBSODIUM_TAG	  := 1.0.18-RELEASE
LIBSODIUM         := libsodium-$(LIBSODIUM_VERSION)
LIBSODIUM_URL     := https://github.com/jedisct1/libsodium/releases/download/$(LIBSODIUM_TAG)/$(LIBSODIUM).tar.gz
LIBSODIUM_SRC     := build/src/$(LIBSODIUM)

$(LIBSODIUM_SRC):
	mkdir -p build/src
	cd build/src && \
	wget -O $(LIBSODIUM).tar.gz $(LIBSODIUM_URL) && \
	tar -xzf $(LIBSODIUM).tar.gz && \
	rm $(LIBSODIUM).tar.gz
