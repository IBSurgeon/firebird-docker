#!/bin/bash

FB_VER="3.0"
FTP_URL="https://github.com/FirebirdSQL/firebird/releases/download/v3.0.11/Firebird-3.0.11.33703-0.amd64.tar.gz"
HQB_URL="https://cc.ib-aid.com/download/distr"

FB_TARBALL=fb.tar.gz
CF_TARBALL=confv.tar.xz
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
    curl --location $url --output $tmp/$fname --progress-bar

    case $? in
      0)  echo "OK";;	
      6)  exit_script 1 "Couldn't resolve host";;
      23) exit_script 1 "Write error";;
      67) exit_script 1 "Wrong login / password";;
      78) exit_script 1 "File $url does not exist on server";;
      *)  exit_script 1 "curl error occured";;
    esac
}

echo Updating and preparing OS ================================================

apt update || exit_script 1 "Update failed"
apt install --no-install-recommends -y net-tools libtommath1 libicu70 wget\
 unzip gettext libncurses5 curl tar tzdata locales sudo mc file xz-utils\
 ca-certificates || exit_script 1 "Failed to install software"
update-ca-certificates
ln -s libtommath.so.1 /usr/lib/x86_64-linux-gnu/libtommath.so.0
locale-gen en_US.UTF-8

echo Downloading FB installer  ================================================

download_file $FTP_URL $TMP_DIR "FB installer"
download_file $HQB_URL/$FB_VER/$CF_TARBALL $TMP_DIR "FB config"

echo Extracting FB installer ==================================================

mkdir $TMP_DIR/fb $TMP_DIR/conf
tar xvf $TMP_DIR/*.gz -C $TMP_DIR/fb --strip-components=1 > /dev/null
tar xvf $TMP_DIR/$CF_TARBALL -C $TMP_DIR/conf  > /dev/null
cd $TMP_DIR/fb

echo Running FB installer =====================================================

yes 'masterkey' | ./install.sh
#./install.sh -silent
cd $OLD_DIR
cp -rf $TMP_DIR/conf/*.conf /opt/firebird

echo Cleanup ==================================================================

if [ -d $TMP_DIR ]; then rm -rf $TMP_DIR; fi

