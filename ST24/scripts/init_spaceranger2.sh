#!/bin/sh 

cd rundir-$1*

OUTFILE="hostinfo"
echo "hostname is >`hostname`<" >> "${OUTFILE}"
uname -a >> "${OUTFILE}"
ls -al >> "${OUTFILE}"
ls -al .. >> "${OUTFILE}"
ls -ald /afs/hep.wisc.edu/ >> "${OUTFILE}"
ls -ald /afs/physics.wisc.edu/ >> "${OUTFILE}"

../run_spaceranger2.sh $@
