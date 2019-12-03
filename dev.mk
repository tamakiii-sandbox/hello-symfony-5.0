.PHONY: all clean

DIR := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))

ENVIRONMENT := development
PORT_HTTP := 8080
NFS_DEVICE_DIR ?= $(shell echo $(DIR) | sed 's|/Users|/System/Volumes/Data/Users|')

all:
	cat $(lastword $(MAKEFILE_LIST))

.env:
	touch $@
	echo "ENVIRONMENT=$(ENVIRONMENT)" >> $@
	echo "PORT_HTTP=$(PORT_HTTP)" >> $@
	echo "NFS_DEVICE_DIR=$(NFS_DEVICE_DIR)" >> $@

clean:
	rm -rf app
	rm -rf .env

