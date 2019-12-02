.PHONY: all clean

PHP := php
COMPOSER := composer

all:
	cat $(lastword $(MAKEFILE_LIST))

app:
	$(COMPOSER) create-project symfony/website-skeleton:5.0.99 $@

clean:
	rm -rf app

