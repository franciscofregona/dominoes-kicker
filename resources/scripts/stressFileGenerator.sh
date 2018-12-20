#!/bin/bash

#Will create something like 200k files of 1KB each for a total of around 800MB.
dd if=/dev/urandom bs=1024 count=204800 | split -a 9 -b 1KB - /srv/data/export/f.

#(smaller run with)
# dd if=/dev/urandom bs=1024 count=2048 | split -a 9 -b 1KB - /srv/data/export/f.

#You won't be able to delete this files with 'rm -rf *'
#In order to delete them: cd into the dir and
#perl -e 'for(<*>){((stat)[9]<(unlink))}'
