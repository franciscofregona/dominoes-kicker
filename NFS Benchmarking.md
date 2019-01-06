The benchmark tests are done with [fio](https://github.com/axboe/fio).

The test parameters are stored in resource/scripts/speedtest.sh, and they are called by the speedtestNfs role.

Fio will attempt to create a 4GB file in our NFS server served directory and read it back in random 4K blocks. This are the results I found:

512MB of RAM, EXT4 filesystem:
READ: io=3621.8MB, aggrb=92276KB/s, minb=92276KB/s, maxb=92276KB/s, mint=40191msec, maxt=40191msec
4 GB of RAM, EXT4 filesystem:
READ: io=3626.9MB, aggrb=128074KB/s, minb=128074KB/s, maxb=128074KB/s, mint=28998msec, maxt=28998msec
4 GB of RAM, EXT2 filesystem:
READ: io=3601.1MB, aggrb=128440KB/s, minb=128440KB/s, maxb=128440KB/s, mint=28717msec, maxt=28717msec
4 GB of RAM, XFS filesystem:
READ: io=3587.8MB, aggrb=130928KB/s, minb=130928KB/s, maxb=130928KB/s, mint=28060msec, maxt=28060msec

Reiserfs and BTRFS were not tested, as I couldn't make them work in less than the 5 minutes I had to allocate to the task.

The biggest impact is seen by simply allowing the O.S. do it's caching magic and upping the RAM for the machine.
XFS performed marginally better than the EXT alternatives, but I would not deem it as superior, just by this metric.

The complete exits for the test are in the testResults directory.