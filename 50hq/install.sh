#!/bin/bash

FB_VER=5.0
FTP_URL="https://cc.ib-aid.com/download/distr"
TMP_DIR=$(mktemp -d)
OLD_DIR=$(pwd -P)

download_file(){
    url=$1
    tmp=$2
    name=$3
    fname=$(basename -- "$url")

    echo "Downloading $name..."
    curl $url --output $tmp/$fname --progress-bar

    case $? in
      0)  echo "OK";;	  
      23) echo "Write error"
          exit 0;;
      67) echo "Wrong login / password"
              exit 0;;
      78) echo "File $fb_url/$fb_file $does not exist on server"
          exit 0;;
    esac
}

#apt update
#apt install --no-install-recommends -y net-tools libtommath1 libicu70 wget unzip  gettext libncurses5 curl tar openjdk-8-jre jsvc tzdata locales sudo mc xz-utils file
#ln -s libtommath.so.1 /usr/lib/x86_64-linux-gnu/libtommath.so.0
#locale-gen "en_US.UTF-8"

## Firebird & Hqbird download
download_file $FTP_URL/$FB_VER/fb.tar.xz $TMP_DIR "FB installer"
#download_file $FTP_URL/$FB_VER/conf.tar.xz $TMP_DIR "FB config files"
download_file $FTP_URL/amvmon.tar.xz $TMP_DIR "AMV & MON installer"
download_file $FTP_URL/distrib.tar.xz $TMP_DIR "DG installer"
download_file $FTP_URL/hqbird.tar.xz $TMP_DIR "HQbird installer"

echo Extracting FB installer ==================================================

mkdir $TMP_DIR/fb $TMP_DIR/conf
tar xvf $TMP_DIR/fb.tar.xz -C $TMP_DIR/fb --strip-components=1 > /dev/null
#tar xvf $TMP_DIR/conf.tar.xz -C $TMP_DIR/conf  > /dev/null
cd $TMP_DIR/fb

echo Running FB installer =====================================================

yes 'masterkey' | ./install.sh
#./install.sh -silent
cd $OLD_DIR
#cp -rf $TMP_DIR/conf/*.conf /opt/firebird

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

chown -R firebird:firebird /opt/hqbird /opt/firebird/firebird.conf /opt/firebird/databases.conf

#echo Registering HQbird ========================================================
#java -jar /opt/hqbird/dataguard.jar -register -regemail="saveincloudtrial@ib-aid.com" -regpaswd="25FCMZXC" -installid=/opt/hqbird/conf/installid.bin -unlock=/opt/hqbird/conf/unlock -license="E"

sed -i 's/^#\s*RemoteAuxPort.*$/RemoteAuxPort = 3059/g' /opt/firebird/firebird.conf
#sed -i 's/ftpsrv.homedir=/ftpsrv.homedir=\/opt\/database/g' /opt/hqbird/conf/ftpsrv.properties
sed -i 's/ftpsrv.passivePorts=40000-40005/ftpsrv.passivePorts=40000-40000/g' /opt/hqbird/conf/ftpsrv.properties

# cleanup
if [ -d $TMP_DIR ]; then rm -rf $TMP_DIR; fi
