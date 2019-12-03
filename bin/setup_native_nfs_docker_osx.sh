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

echo "WARNING: This script will overwrite those files"
echo "- ~/Library/LaunchAgents/com.apple.nfsd.plist"
echo "- ~/Library/LaunchAgents/com.apple.nfsconf.plist"
echo "- /usr/local/etc/exports"
echo "- /usr/local/etc/nfs.conf"
echo -n "Do you wish to proceed? [y]: "
read decision

if [ "$decision" != "y" ]; then
  echo "Exiting. No changes made."
  exit 1
fi

echo ""

echo "== Creating /etc/local/etc/exports"
echo "/System/Volumes/Data/Users/ -alldirs -mapall=$U:$G localhost" > /usr/local/etc/exports

echo "== Creating /usr/local/etc/nfs.conf"
cat <<EOF > /usr/local/etc/nfs.conf
#
# nfs.conf: the NFS configuration file
#
nfs.server.mount.require_resv_port = 0
EOF


echo "== Create .plist files in ~/Library/LaunchDaemons"
cp /System/Library/LaunchDaemons/com.apple.nfsd.plist ~/Library/LaunchAgents/com.apple.nfsd.plist
cp /System/Library/LaunchDaemons/com.apple.nfsconf.plist ~/Library/LaunchAgents/com.apple.nfsconf.plist

plutil -replace Label -string 'com.apple.nfsd.localhost' ~/Library/LaunchAgents/com.apple.nfsd.plist
plutil -replace Label -string 'com.apple.nfsconf.localhost' ~/Library/LaunchAgents/com.apple.nfsconf.plist

plutil -replace KeepAlive.PathState -xml '<dict><key>/usr/local/etc/exports</key><true/></dict>' ~/Library/LaunchAgents/com.apple.nfsd.plist
plutil -replace WatchPaths -xml '<array><string>/usr/local/etc/nfs.conf</string></array>' ~/Library/LaunchAgents/com.apple.nfsconf.plist

launchctl load ~/Library/LaunchAgents/com.apple.nfsd.plist || true
launchctl load ~/Library/LaunchAgents/com.apple.nfsconf.plist || true

launchctl remove com.apple.nfsconf || true

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

echo "== Resetting folder permissions..."
sudo chown -R "$U":"$G" $PWD

echo "== Restarting docker..."
open -a Docker

while ! docker ps > /dev/null 2>&1 ; do sleep 2; done

echo ""
echo "SUCCESS! Now go run your containers 🐳"
