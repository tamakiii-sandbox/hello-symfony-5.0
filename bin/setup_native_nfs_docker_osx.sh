#!/usr/bin/env bash

set -eu

PWD=$(cd $(dirname $0)/..; pwd)

OS=`uname -s`
OS_VERSION_MAJOR=`sw_vers -productVersion | awk -F '.' '{ print $1 }'`
OS_VERSION_MINOR=`sw_vers -productVersion | awk -F '.' '{ print $2 }'`

U=`id -u`
G=`id -g`

if [ $OS != "Darwin" ]; then
  echo "This script is OSX-only. Please do not run it on any other Unix."
  exit 1
fi

if [[ $EUID -eq 0 ]]; then
  echo "This script must NOT be run with sudo/root. Please re-run without sudo." 1>&2
  exit 1
fi

echo ""
echo " +-----------------------------+"
echo " | Setup native NFS for Docker |"
echo " +-----------------------------+"
echo ""

echo "WARNING: This script will shut down running containers."
echo -n "Do you wish to proceed? [y]: "
read decision

if [ "$decision" != "y" ]; then
  echo "Exiting. No changes made."
  exit 1
fi

echo ""

# /etc/nfs.conf
if grep '^nfs.server.mount.require_resv_port = 0' /etc/nfs.conf > /dev/null; then
  echo "Found \"nfs.server.mount.require_resv_port = 0\" in /etc/nfs.conf. OK"
else
  echo "ERROR: Please edit \"/etc/nfs.conf\" like \"sudo vim /etc/nfs.conf\" because of System Integrity Protection."
  echo "````"
  cat /etc/nfs.conf
  echo "nfs.server.mount.require_resv_port = 0"
  echo "````"
  exit 2
fi

# /etc/exports
if grep '/System/Volumes/Data/Users/ -alldirs' /etc/exports > /dev/null; then
  echo "Found \"/System/Volumes/Data/Users/ -alldirs\" in /etc/exports OK"
else
  echo "ERROR: Please edit \"/etc/exports\" like \"sudo vim /etc/exports\" because of System Integrity Protection."
  echo "````"
  echo "/System/Volumes/Data/Users/ -alldirs -mapall=$U:$G localhost"
  echo "````"
  echo "  or as root if you like"
  echo "````"
  echo "/System/Volumes/Data/Users/ -alldirs -mapall=0:0 localhost"
  echo "````"
  exit 3
fi

echo ""

if ! docker ps > /dev/null 2>&1 ; then
  echo "== Waiting for docker to start..."
fi

open -a Docker

while ! docker ps > /dev/null 2>&1 ; do sleep 2; done

echo "== Stopping running docker containers..."
docker-compose down
docker-compose rm -v --stop

osascript -e 'quit app "Docker"'

echo "== Restarting nfsd..."
sudo nfsd restart

echo "== Restarting docker..."
open -a Docker

while ! docker ps > /dev/null 2>&1 ; do sleep 2; done

echo ""
echo "SUCCESS! Now go run your containers 🐳"
