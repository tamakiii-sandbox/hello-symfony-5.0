.PHONY: all install clean

COMPOSER := composer

all:
	cat $(lastword $(MAKEFILE_LIST))

install: \
	vendor

vendor:
	$(COMPOSER) install

clean:
	rm -rf vendor

