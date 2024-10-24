#!/bin/bash

# Стартуем сервис firebird

#/opt/firebird/bin/fbguard -pidfile /var/run/firebird/firebird.pid -daemon -forever

stop_svc() {
    echo "Container stopped, performing cleanup..." >> /stop_svc.log
    ps aux | grep firebird >> /svc.log
    ps aux | grep fbguard >> /svc.log
    kill $(pgrep firebird) >> /svc.log
    ps aux | grep firebird >> /svc.log
    ps aux | grep fbguard >> /svc.log
}

#Trap SIGTERM
trap 'stop_svc' SIGTERM


sudo -H -u firebird /start_svc.sh

exec "$@"


