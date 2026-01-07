#!/bin/sh

ETCD_VER=v3.6.7
DOWNLOAD_URL=https://github.com/etcd-io/etcd/releases/download

TMP_DIR=/tmp/etcd-download
BIN_DIR=/usr/local/bin

rm -rf $TMP_DIR
mkdir -p $TMP_DIR

curl -L ${DOWNLOAD_URL}/${ETCD_VER}/etcd-${ETCD_VER}-linux-amd64.tar.gz \
  -o $TMP_DIR/etcd.tar.gz

tar xzf $TMP_DIR/etcd.tar.gz -C $TMP_DIR --strip-components=1 --no-same-owner

sudo cp $TMP_DIR/etcdctl $BIN_DIR/etcdctl
sudo cp $TMP_DIR/etcdutl $BIN_DIR/etcdutl
sudo chmod +x $BIN_DIR/etcdctl $BIN_DIR/etcdutl
