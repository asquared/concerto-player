#!/bin/bash

. ./config

# build the lccal cache
debootstrap --make-tarball=$RELEASE.cache.tar $RELEASE cocaine

