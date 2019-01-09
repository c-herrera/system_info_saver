#!/bin/bash

echo 58172 - CR - Provisioning 2LM Mixed Mode [50:50] Interleaved_DAX - Linux

#echo Write Test
#fio --name=write --rw=write --direct=1 --ioengine=sync --bs=256k --iodepth=8 --numjobs=16 --runtime=600 --time_based --size=10G --output=fio_write.log --filename=/mnt/p4/fiotest --filename=/mnt/p5/fiotest | tee -a run.log
echo "Read Test"
fio --name=read --rw=read --direct=1 --ioengine=sync --bs=256k --iodepth=8 --numjobs=16 --runtime=600 --time_based --size=10G --output=fio_read.log --filename=/mnt/p4/fiotest --filename=/mnt/p5/fiotest | tee -a run.log
