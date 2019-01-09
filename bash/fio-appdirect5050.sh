#!/bin/bash

echo 58172 - CR - Provisioning 2LM Mixed Mode [50:50] Interleaved_DAX - Linux
fio --name=write --rw=write --direct=1 --ioengine=sync --bs=256k --iodepth=8 --numjobs=16 --runtime=600 --time_based --size=10G --output=fio_write.log --filename=/mnt/p4 --filename=/mnt/pmem5 | tee -a run.log