#!/bin/bash

# Start Firebird but do not daemonize

#/opt/firebird/bin/fbguard -pidfile /var/run/firebird/firebird.pid -daemon -forever
sudo -H -u firebird /opt/firebird/bin/fbguard -pidfile /var/run/firebird/firebird.pid -forever

exec "$@"
