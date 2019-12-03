# hello-symfony-5.0

## How to use
~~~sh
make -f dev.mk install
# or make -f macos.mk install
docker-compose up
open http://localhost:8080/
~~~

## Available options

`dev.mk` and `macos.mk`
~~~sh
make -f {dev,macos}.mk install \
  ENVIRONMENT={development,debug} \
  PORT_HTTP=8888 \
  MOUNT_TYPE={consistent,delegated,cached}
~~~

## Speed test
~~~sh
make -f test.mk consistent CMD="app/bin/console debug:container" TRY=1 UNIQUE=1-time
make -f test.mk delegated CMD="app/bin/console debug:container" TRY=1 UNIQUE=1-time
make -f test.mk cached CMD="app/bin/console debug:container" TRY=1 UNIQUE=1-time
make -f test.mk nfs CMD="app/bin/console debug:container" TRY=1 UNIQUE=1-time
~~~
~~~sh
make -f test.mk inspect/real
make -f test.mk inspect/user
make -f test.mk inspect/sys
~~~
