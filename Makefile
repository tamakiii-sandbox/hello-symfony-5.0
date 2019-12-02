.PHONY: all clean

COMPOSER := composer

all:
	cat $(lastword $(MAKEFILE_LIST))

app:
	$(COMPOSER) create-project symfony/website-skeleton:5.0.99 $@

clean:
	rm -rf app

