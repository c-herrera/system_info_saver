#!/bin/bash
#	File 	: mls1 1lm shell file
#	Target	: Run MLC test app 
#	Notes	: Please do not remove this header, thanks
#	Created : 12/4/2018
#	By      : C. Herrera

log_file_2lm_mlc_prefetch=1
log_file_2lm_stream_prefetch=1
kboption=-1

# Intro
function ToolBanner () {
	echo "Before running this tool, please make a checklist of the following :"
	echo "- Clear the logs from SEL (either via BMC or SELVIEW tool)"
	echo "- Clear the system mesages with the dmesg --clear command"
	echo "After the test is over check for the log files located at :"
	echo " $(pwd)"
	pause
	clear
	echo "To run the MLC 2LM mode test, follow TC to set bios options settings"
	echo "Then copy linux binaries into a folder."
	echo "a) Run test (prefetch options in BIOS are off) "
	echo "b) Run test (prefetch options in BIOS are on )"
	read -p " Choose an option when ready : " kboption
}

#Pause function
function pause(){
	echo "Press the Enter key to continue..."
	read -p "$*"
}


function makeLogheader () {
	echo "Test is $1 " >> $2
	echo "Started at $(date) " >> $2
	echo "===========================================================" >> $2
}

function makeLogfooter () {
	echo "Test done at $(date)" >> $1
	echo "Please review the past section before attaching to test case" >> $1
	echo "============================================================" >> $1
	echo "============================================================"
}

function runTest () {
	echo "====================================================" 
	echo " $1 "
	echo "Test started at $(date)"
	log_file_2lm_mlc_prefetch=$2
	log_file_2lm_stream_prefetch=$3
	# 
	makeLogheader "MLC Normal start " $log_file_2lm_mlc_prefetch
	./mlc_avx512 | tee -a $log_file_2lm_mlc_prefetch
	makeLogfooter $log_file_2lm_mlc_prefetch
	#
	makeLogheader "Running stream tool" $log_file_2lm_stream_prefetch
	./stream| tee -a 2LM_prefetchoff_stream.log
	makeLogfooter $log_file_2lm_stream_prefetch
	echo "Test ended at $(date)"
}


# main start here
clear
ToolBanner

case $kboption in
	a)
	runTest "First set; MLC with options in BIOS : prefecth off" mlc_2lm_prefetchoff_mlc.log stream_2LM_prefetchoff_stream.log
	;;
	b)
	runTest "First set; MLC with options in BIOS : prefecth off" mlc_2lm_prefetchon_mlc.log stream_2LM_prefetchon_stream.log
	;;
	*)
	echo "Not an option, reurun script and try again"
	exit 1
	;;
esac

dmesg --human > dmesg.txt
cat /var/log/messages > messages.txt
echo "Review the logs located at $(pwd), and check the dmesg or messages log if required"
echo "Reached end."

exit

