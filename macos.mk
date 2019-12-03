.PHONY: all clean

all:
	cat $(lastword $(MAKEFILE_LIST))

docker-compose.override.yml: docker/docker-compose.macos.override.yml
	cp $< $@

clean:
	rm -rf docker-compose.override.yml
