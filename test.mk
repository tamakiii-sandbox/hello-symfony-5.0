.PHONY: all consistent delegate cached nkf clean

CMD := php app/bin/console c:c

all: \
	consistent \
	delegated \
	cached \
	nfs

consistent: clean
	make -f dev.mk .env MOUNT_TYPE=$@
	docker-compose config
	docker-compose run --rm php make -C app install
	docker-compose run --rm php time $(CMD)

delegated: clean
	make -f dev.mk .env MOUNT_TYPE=$@
	docker-compose config
	docker-compose run --rm php make -C app install
	docker-compose run --rm php time $(CMD)

cached: clean
	make -f dev.mk .env MOUNT_TYPE=$@
	docker-compose config
	docker-compose run --rm php make -C app install
	docker-compose run --rm php time $(CMD)

nfs: clean
	make -f dev.mk .env MOUNT_TYPE=consistent
	make -f dev.mk docker-compose.override.yml
	docker-compose config
	docker-compose run --rm php make -C app install
	docker-compose run --rm php time $(CMD)

clean:
	docker-compose down -v
	make -f dev.mk clean

