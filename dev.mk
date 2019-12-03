.PHONY: all clean

DIR := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))

ENVIRONMENT := development
PORT_HTTP := 8080
MOUNT_TYPE := consistent
DEVICE_DIR ?= $(realpath $(shell echo $(DIR) | sed 's|/Users|/System/Volumes/Data/Users|'))

all:
	cat $(lastword $(MAKEFILE_LIST))

.env:
	touch $@
	echo "ENVIRONMENT=$(ENVIRONMENT)" >> $@
	echo "PORT_HTTP=$(PORT_HTTP)" >> $@
	echo "MOUNT_TYPE=$(MOUNT_TYPE)" >> $@
	echo "DEVICE_DIR=$(DEVICE_DIR)" >> $@

docker-compose.override.yml:
	cp docker/$@ $@

clean:
	rm -rf .env
	rm -rf docker-compose.override.yml

