#!/bin/bash

FB_VER=3.0
FTP_URL="https://cc.ib-aid.com/download/distr"
TMP_DIR=$(mktemp -d)
OLD_DIR=$(pwd -P)

exit_script(){
	res=$1
	msg=$2
	if [ $res -ne 0 ]; then
		echo "ERROR: $msg"
		exit $res
	else
		exit 0
	fi
}

download_file(){
    url=$1
    tmp=$2
    name=$3
    fname=$(basename -- "$url")

    echo "Downloading $name..."
    curl $url --output $tmp/$fname --progress-bar

    case $? in
      0)  echo "OK";;	
      6)  exit_script 1 "Couldn't resolve host";;
      23) exit_script 1 "Write error";;
      67) exit_script 1 "Wrong login / password";;
      78) exit_script 1 "File $url does not exist on server";;
      *)  exit_script 1 "curl error occured";;
    esac
}

apt update || exit_script 1 "Update failed"
apt install --no-install-recommends -y net-tools libtommath1 libicu70 wget\
 unzip gettext libncurses5 curl tar openjdk-8-jre jsvc tzdata locales sudo\
 mc xz-utils file ca-certificates || exit_script 1 "Failed to install software"
update-ca-certificates
ln -s libtommath.so.1 /usr/lib/x86_64-linux-gnu/libtommath.so.0 
locale-gen en_US.UTF-8

## Firebird & Hqbird download
download_file $FTP_URL/$FB_VER/fb.tar.xz $TMP_DIR "FB installer"
download_file $FTP_URL/$FB_VER/conf.tar.xz $TMP_DIR "FB config files"
download_file $FTP_URL/amvmon.tar.xz $TMP_DIR "AMV & MON installer"
download_file $FTP_URL/distrib.tar.xz $TMP_DIR "DG installer"
download_file $FTP_URL/hqbird.tar.xz $TMP_DIR "HQbird installer"

echo Extracting FB installer ==================================================

mkdir $TMP_DIR/fb $TMP_DIR/conf
tar xvf $TMP_DIR/fb.tar.xz -C $TMP_DIR/fb --strip-components=1 > /dev/null
tar xvf $TMP_DIR/conf.tar.xz -C $TMP_DIR/conf  > /dev/null
cd $TMP_DIR/fb

echo Running FB installer =====================================================

yes 'masterkey' | ./install.sh
#./install.sh -silent
cd $OLD_DIR
cp -rf $TMP_DIR/conf/*.conf /opt/firebird

echo Installing HQbird ========================================================

if [ ! -d /opt/hqbird ]; then 
	echo "Creating directory /opt/hqbird"
        mkdir /opt/hqbird
    else
	echo "Directory /opt/hqbird already exists"
fi

tar xvf $TMP_DIR/amvmon.tar.xz -C /opt/hqbird > /dev/null
tar xvf $TMP_DIR/distrib.tar.xz -C /opt/hqbird > /dev/null
tar xvf $TMP_DIR/hqbird.tar.xz -C /opt/hqbird > /dev/null

if [ ! -d /opt/hqbird/outdataguard ]; then 
	echo "Creating directory /opt/hqbird/outdataguard"
	mkdir /opt/hqbird/outdataguard
    else
        echo "Directory /opt/hqbird/outdataguard already exists"
fi
echo "Running HQbird setup"
sh /opt/hqbird/hqbird-setup
rm -f /opt/firebird/plugins/libfbtrace2db.so 2 > /dev/null

echo Registering HQbird ========================================================

mkdir -p /opt/hqbird/conf/agent/servers/hqbirdsrv
cp -R /opt/hqbird/conf/.defaults/server/* /opt/hqbird/conf/agent/servers/hqbirdsrv
sed -i 's#server.installation.*#server.installation=/opt/firebird#g' /opt/hqbird/conf/agent/servers/hqbirdsrv/server.properties
sed -i 's#server.bin.*#server.bin = ${server.installation}/bin#g' /opt/hqbird/conf/agent/servers/hqbirdsrv/server.properties

java -Djava.net.preferIPv4Stack=true -Djava.awt.headless=true -Xms128m -Xmx192m -XX:+UseG1GC -jar dataguard.jar -config-directory=/opt/hqbird/conf -default-output-directory=/opt/hqbird/outdataguard/ > /dev/null &
sleep 5
java -jar /opt/hqbird/dataguard.jar -register -regemail="dockertrial@ib-aid.com" -regpaswd="H3WA9NNA" -installid=/opt/hqbird/conf/installid.bin -unlock=/opt/hqbird/conf/unlock -license="T"

pkill -f dataguard.jar
sleep 5

echo Registering test database =================================================

mkdir -p /opt/hqbird/conf/agent/servers/hqbirdsrv/databases/test_employee_fdb/
cp -R /opt/hqbird/conf/.defaults/database3/* /opt/hqbird/conf/agent/servers/hqbirdsrv/databases/test_employee_fdb/
java -jar /opt/hqbird/dataguard.jar -regdb="/opt/firebird/examples/empbuild/employee.fdb" -srvver=3 -config-directory="/opt/hqbird/conf" -default-output-directory="/opt/hqbird/outdataguard"
rm -rf /opt/hqbird/conf/agent/servers/hqbirdsrv/databases/test_employee_fdb/

sed -i 's/db.replication_role=.*/db.replication_role=switchedoff/g' /opt/hqbird/conf/agent/servers/hqbirdsrv/databases/*/database.properties
sed -i 's/job.enabled.*/job.enabled=false/g' /opt/hqbird/conf/agent/servers/hqbirdsrv/databases/*/jobs/replmon/job.properties
sed -i 's/^#\s*RemoteAuxPort.*$/RemoteAuxPort = 3059/g' /opt/firebird/firebird.conf
#sed -i 's/ftpsrv.homedir=/ftpsrv.homedir=\/opt\/database/g' /opt/hqbird/conf/ftpsrv.properties
sed -i 's/ftpsrv.passivePorts=40000-40005/ftpsrv.passivePorts=40000-40000/g' /opt/hqbird/conf/ftpsrv.properties
chown -R firebird:firebird /opt/hqbird /opt/firebird/firebird.conf /opt/firebird/databases.conf

# cleanup
if [ -d $TMP_DIR ]; then rm -rf $TMP_DIR; fi
