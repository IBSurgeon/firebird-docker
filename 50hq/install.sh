#!/bin/bash

FB_VER="5.0"
FTP_URL="https://github.com/FirebirdSQL/firebird/releases/download/v5.0.0/Firebird-5.0.0.1306-0-linux-x64.tar.gz"
HQB_URL="https://cc.ib-aid.com/download/distr"

FB_TARBALL=fb.tar.gz
CF_TARBALL=confv.tar.xz
TMP_DIR=$(mktemp -d)
OLD_DIR=$(pwd -P)

download_file(){
    url=$1
    tmp=$2
    name=$3
    fname=$(basename -- "$url")

    echo "Downloading $name from $url to $tmp"
    wget -q --show-progress --progress=bar:force --no-check-certificate $url -O $tmp 2>&1
    
    case $? in
      0)  echo "OK";;	  
      23) echo "Write error"
          exit 0;;
      67) echo "Wrong login / password"
              exit 0;;
      78) echo "File $url does not exist on server"
          exit 0;;
    esac
}

echo Updating and preparing OS ================================================

apt update
apt install --no-install-recommends -y net-tools libtommath1 libicu70 wget unzip gettext libncurses5 curl tar tzdata locales sudo mc file libatomic1
ln -s libtommath.so.1 /usr/lib/x86_64-linux-gnu/libtommath.so.0 
locale-gen "en_US.UTF-8"

echo Downloading FB installer  ================================================

download_file $FTP_URL $TMP_DIR/$FB_TARBALL "FB installer"
download_file $HQB_URL/$FB_VER/$CF_TARBALL $TMP_DIR/$CF_TARBALL "FB config"

echo Extracting FB installer ==================================================

mkdir $TMP_DIR/fb $TMP_DIR/conf
tar xvf $TMP_DIR/$FB_TARBALL -C $TMP_DIR/fb --strip-components=1 > /dev/null
tar xvf $TMP_DIR/$CF_TARBALL -C $TMP_DIR/conf  > /dev/null
cd $TMP_DIR/fb

echo Running FB installer =====================================================

yes 'masterkey' | ./install.sh
#./install.sh -silent
cd $OLD_DIR
cp -rf $TMP_DIR/conf/*.conf /opt/firebird

echo Cleanup ==================================================================

if [ -d $TMP_DIR ]; then rm -rf $TMP_DIR; fi

