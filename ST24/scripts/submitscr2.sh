#!/bin/sh 
while IFS=, read -r id set sn well transcriptome
do 
  while :
  do
    DATE="`date +%Y%m%d-%H%M%S`"
    RND="`tr -dc A-Za-z0-9 < /dev/urandom | head -c3`"
    RUNDIR="rundir-${id}-${DATE}-${RND}"
    if [ ! -d "{RUNDIR}" ]; then
      echo "using ${RUNDIR}"
      break
    fi
  done

  mkdir "${RUNDIR}"

  #cp condor_files.tar.gz ${RUNDIR}
  #echo "Unzipping pertinent files into ${RUNDIR}"
  #cd ${RUNDIR}
  #tar xzvf ../condor_files.tar.gz
  #cd ..
  #echo "Done unzipping"

  SUBMIT="${RUNDIR}/submit-${DATE}-${RND}"
  cat > "${SUBMIT}" << EOF
Executable 	= ./init_spaceranger2.sh
Log 		= ${RUNDIR}/condor.log 
Output 		= ${RUNDIR}/stdout
Error 		= ${RUNDIR}/stderr
Arguments	= "${id} ${set} ${sn} ${well}"
should_transfer_files = YES
transfer_input_files = init_spaceranger2.sh,run_spaceranger2.sh,${RUNDIR},fastqs/${id},spaceranger-3.1.1,HE_slides/${set}/${sn}-A${well}.tif,ref/${transcriptome}
transfer_output_files = ${RUNDIR}
request_disk = 100G
request_memory = 32G
request_cpus = 16
periodic_release = ((JobStatus==5) && (CurrentTime - EnteredCurrentStatus) > 30)
max_retries=20
Queue
EOF

  condor_submit "${SUBMIT}"
done < files.conf 
