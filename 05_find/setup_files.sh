#!/bin/bash

rm -rf files
mkdir -p files
cd files

base_dir=$PWD
wget -O words.txt https://users.cs.duke.edu/~ola/ap/linuxwords

# make a deep directory structure
mkdir deep && cd deep
for file in {a..z}; do
    mkdir $file && cd $file
done
echo "hello" > text.txt

cd $base_dir

# make a wide directory structure with some larger files
mkdir wide && cd wide
for file in $(shuf -n 100 $base_dir/words.txt) ; do
    touch $file.txt
    # occasionally make a 150 kb file
    if [[ $(($(($RANDOM%100))%7)) == 0 ]] ; then
        base64 /dev/urandom | head -c 150000 > $file.txt
    fi
done

# tree structure
mkdir $base_dir/tree
for file in $(shuf -n 10 $base_dir/words.txt) ; do
    cd $base_dir/tree
    mkdir $file && cd $file
    for file in $(shuf -n 10 $base_dir/words.txt) ; do
        touch $file.txt
    done
done

# hide a needle
echo "needle" > $file.txt

rm $base_dir/words.txt
