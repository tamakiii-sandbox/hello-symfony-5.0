.PHONY: all consistent delegate cached nkf clean

all: \
	consistent \
	delegated \
	cached \
	nfs

consistent: clean
	make -f dev.mk .env MOUNT_TYPE=$@
	docker-compose config
	docker-compose run --rm php make -C app install
	docker-compose run --rm php time php app/bin/console c:c

delegated: clean
	make -f dev.mk .env MOUNT_TYPE=$@
	docker-compose config
	docker-compose run --rm php make -C app install
	docker-compose run --rm php time php app/bin/console c:c

cached: clean
	make -f dev.mk .env MOUNT_TYPE=$@
	docker-compose config
	docker-compose run --rm php make -C app install
	docker-compose run --rm php time php app/bin/console c:c

nfs: clean
	make -f dev.mk .env MOUNT_TYPE=consistent
	make -f dev.mk docker-compose.override.yml
	docker-compose config
	docker-compose run --rm php make -C app install
	docker-compose run --rm php time php app/bin/console c:c

clean:
	docker-compose down -v
	make -f dev.mk clean

