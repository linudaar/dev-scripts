#!/bin/bash

cb_app="/Applications/Couchbase Server.app"
cb_path="$cb_app/Contents/Resources/couchbase-core/bin"
cb_user=Administrator
cb_pw=password
cb_cli="$cb_path/couchbase-cli"
cb_host="127.0.0.1:8091"
tmp=./tmp

function list() {
    "$cb_cli" bucket-list -c $cb_host -u $cb_user -p $cb_pw 
}

# clean the couchbase server
function clean() {
    for bucketname in ${@:2}
    do
       echo "Deleting bucket '$bucketname'..."
       "$cb_cli" bucket-flush -c $cb_host -u $cb_user -p $cb_pw --bucket=$bucketname --force 
    done
}

function init() {
    echo "Initliazing cluster..."
    "$cb_cli" cluster-init  -c $cb_host -u $cb_user -p $cb_pw --cluster-init-username=$cb_user --cluster-init-password=$cb_pw --cluster-init-ramsize=512
    for bucketname in ${@:2}
    do
       echo "Initializing bucket '$bucketname'..."
       "$cb_cli" bucket-create -c $cb_host -u $cb_user -p $cb_pw --bucket=$bucketname --bucket-ramsize=100 --enable-flush=1    
    done
}

function delete() {
    for bucketname in ${@:2}
    do
       echo "Deleting bucket '$bucketname'..."
       "$cb_cli" bucket-delete -c $cb_host -u $cb_user -p $cb_pw --bucket=$bucketname 
    done
}

function install() {
    if [ -e "$cb_app" ]
    then
        echo "Couchbase is already installed at $cb_app."
        return
    fi

    local zip="$tmp/couchbase.zip"
    if [ -e "$zip" ]
    then
        echo "Couchbase using existing zip $zip."
    else
        curl -o "$zip" http://packages.couchbase.com/releases/3.0.1/couchbase-server-community_3.0.1-macos_x86_64.zip
    fi

    local ltmp="$tmp/couchbase.unzip"
    if [ -e "$ltmp" ]
    then
        rm -rf "$ltmp/*"
    else
        mkdir "$ltmp"
    fi

    unzip "$zip" -d $ltmp

    cp -R "$ltmp/Couchbase Server.app" /Applications

    rm -rf "$ltmp"
}

function uninstall() {
    stop

    rm -rf "$cb_app"
    rm -rf "/Library/Application Support/Couchbase"
    rm -rf "~/Library/Application Support/Couchbase"
}

function start() {
    open "/Applications/Couchbase Server.app"
}

function stop() {
    pkill "Couchbase Server"
}

function usage() {
   echo "Usage: couchbase.sh COMMAND [buckets]"
   echo "COMMANDS:"
   echo "  install"
   echo "  init [buckets]"
   echo "  clean [buckets]"
   echo "  delete [buckets]"
   echo "  start"
   echo "  stop"
   echo "  list"
   echo "  uninstall" 


}


case $1 in
         "") usage;;
  "install") install;;
     "init") init $@;;
    "clean") clean $@;;
   "delete") delete $@;;
    "start") start;;
     "stop") stop;;
"uninstall") uninstall;;
     "list") list $@;;
esac
