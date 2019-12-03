.PHONY: all clean

DIR := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))

ENVIRONMENT := development
PORT_HTTP := 8080
MOUNT_TYPE := consistent
CURRENT_VOLUME_DIR ?= $(realpath $(shell echo $(DIR) | sed 's|/Users|/System/Volumes/Data/Users|'))

all:
	cat $(lastword $(MAKEFILE_LIST))

.env:
	touch $@
	echo "ENVIRONMENT=$(ENVIRONMENT)" >> $@
	echo "PORT_HTTP=$(PORT_HTTP)" >> $@
	echo "MOUNT_TYPE=$(MOUNT_TYPE)" >> $@
	echo "CURRENT_DIR=$(DIR)" >> $@
	echo "CURRENT_VOLUME_DIR=$(CURRENT_VOLUME_DIR)" >> $@

docker-compose.override.yml: docker/docker-compose.override.yml
	cp $< $@

clean:
	rm -rf .env
	rm -rf docker-compose.override.yml

