#!/bin/bash

# Стартуем сервис firebird
sudo -H -u firebird /opt/firebird/bin/fbguard -pidfile /var/run/firebird/firebird.pid -forever

exec "$@"
