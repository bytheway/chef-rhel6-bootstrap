#!/bin/bash

mkdir -p chef-build
cd chef-build

yum install -y gcc libtool libicu-devel openssl-devel autoconf213 gcc-c++

#####################################################
#build erlang for couch

if [ ! -f curl-7.25.0.tar.gz ]; then
  wget http://www.erlang.org/download/otp_src_R15B01.tar.gz
fi

tar -xzf otp_src_R15B01.tar.gz
cd otp_src_R15B01

./configure --prefix=/usr/local/erlang --without-termcap --without-javac --enable-smp-support --disable-hipe
make
make install
cd ..

######################################################
# install curl for couch
if [ ! -f curl-7.25.0.tar.gz ]; then
  wget http://curl.haxx.se/download/curl-7.25.0.tar.gz
fi

tar -xzf curl-7.25.0.tar.gz
cd curl-7.25.0
./configure --prefix=/usr/local/couchdb/curl
make
make install
cd ..

####################################################
# install spidermonkey for couch

if [ ! -f curl-7.25.0.tar.gz ]; then
    wget http://ftp.mozilla.org/pub/mozilla.org/js/js185-1.0.0.tar.gz
fi

tar xzf js185-1.0.0.tar.gz 
cd js-1.8.5/js/src/
autoconf-2.13 
./configure --prefix=/usr/local/couchdb/js
make
make install
cd ..

###################################################
# install couchdb

ERL=/usr/local/erlang/bin/erl ERLC=/usr/local/erlang/bin/erlc CURL_CONFIG=/usr/local/couchdb/curl/bin/curl-config LDFLAGS=-L/usr/local/couchdb/curl/lib ./configure --prefix=/usr/local/couchdb/couchdb --with-erlang=/usr/local/erlang/lib/erlang/usr/include/ -with-js-lib=/usr/local/couchdb/js/lib/ --with-js-include=/usr/local/couchdb/js/include/js/
make
make install
cd ..







