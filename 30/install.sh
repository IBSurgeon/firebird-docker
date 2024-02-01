#!/bin/bash

# Firebird 3.0
FTP_URL="https://github.com/FirebirdSQL/firebird/releases/download/v3.0.11/Firebird-3.0.11.33703-0.amd64.tar.gz"


FB_TARBALL=fb.tar.gz
TMP_DIR=$(mktemp -d)
OLD_DIR=$(pwd -P)

echo Downloading FB installer  ================================================

wget -q --show-progress --progress=bar:force --no-check-certificate $FTP_URL -O $TMP_DIR/$FB_TARBALL 2>&1

case $? in
    0) echo "OK";;
    1) echo "Generic error"
       exit 0;;
    2) echo "Parse error"
       exit 0;;
    3) echo "File I/O error"
      exit 0;;
    4) echo "Network failure"
      exit 0;;
    5) echo "SSL verification failure"
      exit 0;;
    6) echo "Username/password authentication failure"
      exit 0;;
    7) echo "Protocol errors"
      exit 0;;
    8) echo "Server issued an error response"
      exit 0;;
esac

echo Extracting FB installer ==================================================

mkdir $TMP_DIR/fb
tar xvf $TMP_DIR/$FB_TARBALL -C $TMP_DIR/fb --strip-components=1 > /dev/null
#tar xvf $TMP_DIR/conf.tar.xz -C $TMP_DIR/conf  > /dev/null
cd $TMP_DIR/fb

echo Running FB installer =====================================================

yes 'masterkey' | ./install.sh
#./install.sh -silent

echo Cleanup ==================================================================

cd $OLD_DIR
if [ -d $TMP_DIR ]; then rm -rf $TMP_DIR; fi

