#!/bin/sh
set -e
COUCH_TOP=`pwd`
export COUCH_TOP
export RELAX=`cygpath $RELAX`

if [ ! -e "$COUCH_TOP/configure" ]
then
    echo ============= COUCHDB_CONFIG BOOTSTRAP ====================
    ./bootstrap 2>&1 | tee $COUCH_TOP/build_configure.txt
fi

echo ============= COUCHDB_CONFIG CONFIGURE ===================
./configure \
--prefix=$ERL_TOP/release/win32 \
--with-erlang=$ERL_TOP/release/win32/usr/include \
--with-win32-icu-binaries=$RELAX/icu \
--with-openssl-bin-dir=$RELAX/openssl/bin \
--with-msvc-redist-dir=$ERL_TOP/.. \
--with-js-lib=$RELAX/js-1.8.5/js/src/dist/lib \
--with-js-include=$RELAX/js-1.8.5/js/src/dist/include \
--disable-init \
--disable-launchd \
#--with-win32-curl=$COUCH_TOP/../curl \
2>&1 | tee -a $COUCH_TOP/build_configure.txt

echo ============= COUCHDB_CONFIG CONFIGURE ===================
echo DONE. | tee -a $COUCH_TOP/build_configure.txt
