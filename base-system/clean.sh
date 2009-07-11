#!/bin/bash

if [ "`whoami`" != "root" ]; then
    echo "Sudo-ing ourselves..."
    exec sudo $0 $@
fi

rm -rf staging_dir
