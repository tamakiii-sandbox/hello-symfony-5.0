.PHONY: all consistent delegate cached nkf clean

DIR := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))
SELF := $(DIR)/$(lastword $(MAKEFILE_LIST))
LOGDIR := /tmp

CMD := app/bin/console debug:container
TRY := 1
NUMBERS := $(shell seq $(TRY) | xargs echo)

UNIQUE := default

all: /tmp
	$(MAKE) -f $(SELF) consistent CMD="$(CMD)" TRY=$(TRY) | tee $(LOGDIR)/test.mk.$(UNIQUE).consistent.log
	$(MAKE) -f $(SELF) delegated CMD="$(CMD)" TRY=$(TRY) | tee $(LOGDIR)/test.mk.$(UNIQUE).delegated.log
	$(MAKE) -f $(SELF) cached CMD="$(CMD)" TRY=$(TRY) | tee $(LOGDIR)/test.mk.$(UNIQUE).cached.log
	$(MAKE) -f $(SELF) nfs CMD="$(CMD)" TRY=$(TRY) | tee $(LOGDIR)/test.mk.$(UNIQUE).nfs.log

inspect: \
	inspect/real \
	inspect/user \
	inspect/sys

inspect/%:
	grep -Ri --color '^$(@F)' $(LOGDIR)/test.mk.$(UNIQUE).consistent.log
	grep -Ri --color '^$(@F)' $(LOGDIR)/test.mk.$(UNIQUE).delegated.log
	grep -Ri --color '^$(@F)' $(LOGDIR)/test.mk.$(UNIQUE).cached.log
	grep -Ri --color '^$(@F)' $(LOGDIR)/test.mk.$(UNIQUE).nfs.log

consistent: clean
	make -f dev.mk .env MOUNT_TYPE=$@
	docker-compose config
	docker-compose run --rm php make -C app install
	vm_stat
	for i in $(NUMBERS); do \
		docker-compose run --rm php time $(CMD); \
	done
	vm_stat

delegated: clean
	make -f dev.mk .env MOUNT_TYPE=$@
	docker-compose config
	docker-compose run --rm php make -C app install
	vm_stat
	for i in $(NUMBERS); do \
		docker-compose run --rm php time $(CMD); \
	done
	vm_stat

cached: clean
	make -f dev.mk .env MOUNT_TYPE=$@
	docker-compose config
	docker-compose run --rm php make -C app install
	vm_stat
	for i in $(NUMBERS); do \
		docker-compose run --rm php time $(CMD); \
	done
	vm_stat

nfs: clean
	make -f dev.mk .env MOUNT_TYPE=consistent
	make -f dev.mk docker-compose.override.yml
	docker-compose config
	docker-compose run --rm php make -C app install
	vm_stat
	for i in $(NUMBERS); do \
		docker-compose run --rm php time $(CMD); \
	done
	vm_stat

clean:
	docker-compose down -v
	make -f dev.mk clean

