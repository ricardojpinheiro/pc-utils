# pc-utils
Several PC utils that I created to help using my MSXs.

## slackspace.sh
It's a utility written in shell script to help calculating the slack space
in different partition sizes, from 128 Mb to 4 Gb. I developed it to help
me, to know the best partition scheme to my SD-cards that I'm using in my
MSXs. As you may know, MSX (using
[Nextor](https://github.com/Konamiman/Nextor)) can handle with FAT 16
partitions, but slack space (the differenct between sectors and clusters)
can be awful. So, this script helped me to know which partition size is the
best, in order to minimize slack space.