#!/bin/bash

# Стартуем сервис firebird

#/opt/firebird/bin/fbguard -pidfile /var/run/firebird/firebird.pid -daemon -forever

# Start java services

sudo -H -u firebird /start_svc.sh

exec "$@"
