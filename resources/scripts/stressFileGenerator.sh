#!/bin/bash
#This script will create something like 200k files of 1KB each for a total of around 800MB.
#But I'm trying to first find out how many files are already there, so achieving some kind of idempotence.

COUNT=`ls -1 /srv/data/export | wc -l`

if [ "$COUNT" -lt 100 ];then
        dd if=/dev/urandom bs=1024 count=204800 | split -a 9 -b 1KB - /srv/data/export/f.
        #(smaller run with)
		# dd if=/dev/urandom bs=1024 count=2048 | split -a 9 -b 1KB - /srv/data/export/f.

fi

#Generate a list of known name of random files
ls /srv/data/export -1 | sort -R | head -n 1000 | xargs -0 -d '\n' -I '{}' echo 'wget localhost:8081/{} -O /dev/null/' > /srv/data/export/randomlist

#You won't be able to delete this files with 'rm -rf *'
#In order to delete them: cd into the dir and
#perl -e 'for(<*>){((stat)[9]<(unlink))}'


