#!/bin/bash
#

sed "$1q;d" files.conf | (while IFS=, read id set sn well trans
do
	echo $id
done)
