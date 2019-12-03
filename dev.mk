.PHONY: all clean

ENVIRONMENT := development
PORT_HTTP := 8080

all:
	cat $(lastword $(MAKEFILE_LIST))

.env:
	touch $@
	echo "ENVIRONMENT=$(ENVIRONMENT)" >> $@
	echo "PORT_HTTP=$(PORT_HTTP)" >> $@

clean:
	rm -rf app
	rm -rf .env

