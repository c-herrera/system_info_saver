#!/bin/bash
#	File 	: mls1 1lm shell file
#	Target	: Run MLC test app 
#	Notes	: Please do not remove this header, thanks
#	Created : 12/4/2018
#	By      : C. Herrera


log_file_1lm_mlc_prefetch=1
log_file_1lm_stream_prefetch=1

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
	echo "To run the MLC 1LM mode test, follow TC to set bios options settings"
	echo "Then copy linux binaries into a folder."
	echo "Make sure than AEP modules are already mounted, run "
	echo "the gen_perthreadfile.sh and check if it has already generated the required file."
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
	log_file_1lm_mlc_prefetch=$2
	log_file_1lm_stream_prefetch=$3
	# step 7 of test
	makeLogheader "MLC Normal start " $log_file_1lm_mlc_prefetch
	./mlc_avx512 2>&1 | tee -a  $log_file_1lm_mlc_prefetch
	makeLogfooter $log_file_1lm_mlc_prefetch
	# Step 8
	makeLogheader "MLC Latency matrix start" $log_file_1lm_mlc_prefetch
	./mlc_avx512 --latency_matrix -x0 2>&1 | tee -a  $log_file_1lm_mlc_prefetch
	makeLogfooter $log_file_1lm_mlc_prefetch
	# step 9
	makeLogheader "MLC idle lantency on PMEM Storage" $log_file_1lm_mlc_prefetch
	for dir in $(lsblk | grep -i "pmem"  | awk '{print $7 }' )
	do
		./mlc_avx512 --idle_latency -c0 -J${dir} 2>&1 | tee -a  $log_file_1lm_mlc_prefetch
	done
	makeLogfooter $log_file_1lm_mlc_prefetch
	# Step 10
	makeLogheader "MLC Loaded Latency using threads" $log_file_1lm_mlc_prefetch
	./mlc_avx512 --loaded_latency -T -d0 -operthreadfile.txt 2>&1 | tee -a  $log_file_1lm_mlc_prefetch
	makeLogfooter $log_file_1lm_mlc_prefetch
	# Step 11
	makeLogheader "Running stream tool" $log_file_1lm_stream_prefetch
	./stream | tee -a $log_file_1lm_stream_prefetch
	makeLogfooter $log_file_1lm_stream_prefetch
	echo "Test ended at $(date)"
}

# main start here
clear
ToolBanner
case $kboption in
	a)
	runTest "First set; MLC with options in BIOS : prefecth off" mlc_1lm_prefetch_off.out stream_1lm_prefetch_off.log
	;;
	b)
	runTest "Second set; MLC with options prefecth on" mlc_1lm_prefetch_on.out stream_1lm_prefetch_on.log
	;;
	*)
	echo "Not an option. Please run this script again"
	exit 1
	;;
esac

if [ -x "$(command -v selview)" ]; then 
	selview /save $LogDir/sut_$(date +%Y:%m:%d:%H:%M:%S).sel
	selview /save /hex $LogDir/sut_$(date +%Y:%m:%d:%H:%M:%S)_hex.sel
fi


dmesg --human > dmesg.txt
cat /var/log/messages > messages.txt

echo "Review the logs located at $(pwd), and check the dmesg or messages log if required"
echo "Reached end."

exit

