#!/bin/bash

mkdir -p chef-build
cd chef-build


if [ -n "$1" ]; then
  STEP=$1
  echo "Skipping to step: $STEP"
else
  STEP=1
fi

yum install -y gcc libtool libicu-devel openssl-devel autoconf213 gcc-c++

if [ $STEP -le 1 ]; then
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

  cd /usr/local/bin
  ln -s /usr/local/erlang/bin/erl
  cd -

  STEP=2
fi

if [ $STEP -le 2 ]; then

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

  STEP=3
fi


if [ $STEP -le 3 ]; then

  ####################################################
  # install spidermonkey for couch

  if [ ! -f js185-1.0.0.tar.gz ]; then
      wget http://ftp.mozilla.org/pub/mozilla.org/js/js185-1.0.0.tar.gz
  fi

  tar xzf js185-1.0.0.tar.gz 
  cd js-1.8.5/js/src/
  autoconf-2.13 
  ./configure --prefix=/usr/local/couchdb/js
  make
  make install
  cd ..

  STEP=4
fi

if [ $STEP -le 4 ]; then

  ###################################################
  # install couchdb

  if [ ! -f apache-couchdb-1.2.0.tar.gz ]; then
    wget http://linux-files.com/couchdb/releases/1.2.0/apache-couchdb-1.2.0.tar.gz
  fi

  tar xzf apache-couchdb-1.2.0.tar.gz
  cd apache-couchdb-1.2.0

  ERL=/usr/local/erlang/bin/erl ERLC=/usr/local/erlang/bin/erlc CURL_CONFIG=/usr/local/couchdb/curl/bin/curl-config LDFLAGS=-L/usr/local/couchdb/curl/lib ./configure --prefix=/usr/local/couchdb/couchdb --with-erlang=/usr/local/erlang/lib/erlang/usr/include/ -with-js-lib=/usr/local/couchdb/js/lib/ --with-js-include=/usr/local/couchdb/js/include/js/
  make
  make install
  cd ..

  STEP=5
fi


if [ $STEP -le 5 ]; then

  ###################################################
  # install rabbitmq

  if [ ! -f rabbitmq-server-generic-unix-2.8.1.tar.gz ]; then
    wget http://www.rabbitmq.com/releases/rabbitmq-server/v2.8.1/rabbitmq-server-generic-unix-2.8.1.tar.gz
  fi

  tar xzf rabbitmq-server-generic-unix-2.8.1.tar.gz
  mv rabbitmq_server-2.8.1 /usr/local/rabbitmq

  STEP=6
fi

if [ $STEP -le 6 ]; then

  ###################################################
  # configure rabbitmq

  pushd /usr/local/rabbitmq/sbin

  ./rabbitmq-server -detached
  sleep 5

  ./rabbitmqctl add_vhost /chef
  ./rabbitmqctl add_user chef testing
  ./rabbitmqctl set_permissions -p /chef chef ".*" ".*" ".*"

  ./rabbitmqctl stop

  popd
 
  STEP=7
fi

if [ $STEP -le 7 ]; then

  ###################################################
  # configure gecode


  if [ ! -f gecode-3.7.2.tar.gz ]; then
    wget http://www.gecode.org/download/gecode-3.7.2.tar.gz
  fi

  tar zxvf gecode-3.7.2.tar.gz
  cd gecode-3.7.2 && ./configure
  make && make install
 
  STEP=8
fi


