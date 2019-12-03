.PHONY: all clean

all:
	cat $(lastword $(MAKEFILE_LIST))

install: \
	.env \
	docker-compose.override.yml

.env:
	$(MAKE) -f dev.mk $@

docker-compose.override.yml: docker/docker-compose.macos.override.yml
	cp $< $@

clean:
	rm -rf .env
	rm -rf docker-compose.override.yml
