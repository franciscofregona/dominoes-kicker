#100M
#dd if=/dev/urandom bs=1024 count=10240 | split -a 7 -b 1KB - f.
#2GB
dd if=/dev/urandom bs=1024 count=204800 | split -a 9 -b 1KB - f.

#fast delete: cd into the dir and
#perl -e 'for(<*>){((stat)[9]<(unlink))}'
