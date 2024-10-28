#!/bin/bash

export JAVA_HOME=/usr/bin/java
export DG_USER=firebird
export TMP_DIR=/var/tmp

OLD_DIR=$(pwd -P)

# HQbird =========================

cd /opt/hqbird
/usr/bin/java -Djava.net.preferIPv4Stack=true -Djava.awt.headless=true -Xms128m -Xmx192m -XX:+UseG1GC -jar dataguard.jar -config-directory=/opt/hqbird/conf -default-output-directory=/opt/hqbird/outdataguard/ &
sleep 5

# AMV ============================

unset PID_FILE CLASSPATH DG_OPTS MON4_HOME
export MON4_HOME=/opt/hqbird/amv
export PID_FILE=/var/run/fbccamv.pid
export DG_OPTS="-Djava.net.preferIPv4Stack=true -Xmx192m "
export CLASSPATH=$MON4_HOME/amv.jar

cd /opt/hqbird/amv
/usr/bin/java -Xmx256m -cp amv.jar Main &
sleep 5

# Launcher =======================

unset PID_FILE CLASSPATH DG_OPTS MON4_HOME
export MON4_HOME=/opt/hqbird/mon
export PID_FILE=/var/run/fbcclauncher.pid
export DG_OPTS="-Djava.net.preferIPv4Stack=true -Xmx192m "
export CLASSPATH=$MON4_HOME/bin/fbcclauncher.jar

cd /opt/hqbird/mon/bin
/usr/bin/java -Xmx256m  -jar fbcclauncher.jar &

# TraceHorse =====================

unset PID_FILE
export MON4_HOME=/opt/hqbird/mon
export PID_FILE=/var/run/fbcctracehorse.pid
export DG_OPTS="-Djava.net.preferIPv4Stack=true -Xmx192m "
export CLASSPATH=$MON4_HOME/bin/tracehorse.jar

cd /opt/hqbird/mon/bin
/usr/bin/java -Xmx256m -jar tracehorse.jar &

# Firebird =======================
# Start Firebird but do not daemonize

#/opt/firebird/bin/fbguard -pidfile /var/run/firebird/firebird.pid -daemon -forever
/opt/firebird/bin/fbguard -pidfile /var/run/firebird/firebird.pid -forever

cd $OLD_DIR
