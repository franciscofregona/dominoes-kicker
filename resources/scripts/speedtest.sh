#!/bin/bash
# { time (ls -1 | sort -R | head -n 1000 | xargs cat ); } 2> /srv/data/export/results-$1

cd /srv/data/export/
sync;fio --randrepeat=1 --ioengine=libaio --direct=1 --gtod_reduce=1 --name=test --filename=test --bs=4k --iodepth=64 --size=600M --readwrite=randread --ramp_time=4 > results-$1