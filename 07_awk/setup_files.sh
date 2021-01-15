#!/bin/bash

rm -rf files

if [[ ! -d ../02_misc/files ]] ; then
    cd ../02_misc
    ./setup_files.sh
    cd - > /dev/null
fi

ln -s ../02_misc/files files
