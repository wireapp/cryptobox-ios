CRYPTOBOX_VERSION := v1.1.1
CRYPTOBOX         := cryptobox-$(CRYPTOBOX_VERSION)
CRYPTOBOX_GIT_URL := git@github.com:wireapp/cryptobox-c.git
CRYPTOBOX_SRC     := build/src/$(CRYPTOBOX)

$(CRYPTOBOX_SRC):
	mkdir -p build/src
	cd build/src && \
	git clone $(CRYPTOBOX_GIT_URL) $(CRYPTOBOX) && \
	cd $(CRYPTOBOX) && \
	git checkout $(CRYPTOBOX_VERSION)
