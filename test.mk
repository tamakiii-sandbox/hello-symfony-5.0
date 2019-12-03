.PHONY: all consistent delegate cached nkf clean

DIR := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))
SELF := $(DIR)/$(lastword $(MAKEFILE_LIST))

CMD := app/bin/console debug:container
TRY := 1
NUMBERS := $(shell seq $(TRY) | xargs echo)

UNIQUE := default

all:
	$(MAKE) -f $(SELF) consistent CMD="$(CMD)" TRY=$(TRY) > /tmp/test.mk.$(UNIQUE).consistent.log
	$(MAKE) -f $(SELF) delegated CMD="$(CMD)" TRY=$(TRY) > /tmp/test.mk.$(UNIQUE).delegated.log
	$(MAKE) -f $(SELF) cached CMD="$(CMD)" TRY=$(TRY) > /tmp/test.mk.$(UNIQUE).cached.log
	$(MAKE) -f $(SELF) nfs CMD="$(CMD)" TRY=$(TRY) > /tmp/test.mk.$(UNIQUE).nfs.log

inspect: \
	inspect/real \
	inspect/user \
	inspect/sys

inspect/%:
	grep -Ri --color '^$(@F)' /tmp/test.mk.$(UNIQUE).consistent.log
	grep -Ri --color '^$(@F)' /tmp/test.mk.$(UNIQUE).delegated.log
	grep -Ri --color '^$(@F)' /tmp/test.mk.$(UNIQUE).cached.log
	grep -Ri --color '^$(@F)' /tmp/test.mk.$(UNIQUE).nfs.log

consistent: clean
	make -f dev.mk .env MOUNT_TYPE=$@
	docker-compose config
	docker-compose run --rm php make -C app install
	for i in $(NUMBERS); do \
		docker-compose run --rm php time $(CMD); \
	done

delegated: clean
	make -f dev.mk .env MOUNT_TYPE=$@
	docker-compose config
	docker-compose run --rm php make -C app install
	for i in $(NUMBERS); do \
		docker-compose run --rm php time $(CMD); \
	done

cached: clean
	make -f dev.mk .env MOUNT_TYPE=$@
	docker-compose config
	docker-compose run --rm php make -C app install
	for i in $(NUMBERS); do \
		docker-compose run --rm php time $(CMD); \
	done

nfs: clean
	make -f dev.mk .env MOUNT_TYPE=consistent
	make -f dev.mk docker-compose.override.yml
	docker-compose config
	docker-compose run --rm php make -C app install
	for i in $(NUMBERS); do \
		docker-compose run --rm php time $(CMD); \
	done

clean:
	docker-compose down -v
	make -f dev.mk clean
	rm -rf /tmp/test.mk.*.consistent.log
	rm -rf /tmp/test.mk.*.delegated.log
	rm -rf /tmp/test.mk.*.cached.log
	rm -rf /tmp/test.mk.*.nfs.log

