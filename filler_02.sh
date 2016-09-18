#!/bin/bash
# 	File          : filler_02.sh
#	Date          : 05-31-2016
#	Program name  : space filler
#	Version       : 0.0.2
#	Author        : ----
#	Enviroment    : CLI
#	Description   : This little script will try to create several
#					folders and files inside them, the size of each file is
#					3.9 KiB (4010 bytes)
#	Notes         : Not optimized at all, just to test the speed of my system
#
#
#
# Some vars to start
today=$(date)
host=$(hostname)
linuxver=$(uname -r)
filler_version=0.0.2
PCT=0
# the data to copy
datatofile="1010101010101010101010101010101"
limit=0
# Case vars to catch from dialog
DIALOG_CANCEL=1
DIALOG_ESC=255
HEIGHT=0
WIDTH=0
# Width and height of the gauge window
RHEIGHT=22
RWIDTH=77
# The ouput temp file to use
OUTPUT=$HOME/output.temp$$   #/home/versus/bin/output.tmp$$
TMPFILE=$HOME/testfile.tmp$$ #/home/versus/bin/testfile.tmp$$

# trap and delete temp files
trap "rm $OUTPUT; rm $TMPFILE; exit" SIGHUP SIGINT SIGTERM

function copy_test_1(){
	echo "---------------------------------------------------------"
	echo " This test started at : $today"
	echo " First test , write multiple files using a fixed 32 character line"
	echo " The test will run for $limit times"
	for (( i=0; i <limit; i++))
	do
		echo " Creating folder 'folder_$i'"
		mkdir "folder_"$i
		cd "folder_"$i
		for (( b= 0; b < limit; b++))
		do
			touch "file_"$b
			for (( f=0; f < 128; f++))
			do
				echo $datatofile >> "file_"$b
			done
		done
		echo " Done with 'folder_$i' at $(date +%I:%M:%S:%N)"
		cd ..
	done
	today=$(date)
	echo " Test ended at '$today'"
}


function copy_test_2(){
	echo "---------------------------------------------------------"
	echo " Second test, copying of a created file of 4.0 KiB lenght"
	echo " The test will run for $limit times"
	for (( r = 0; r < limit; r++))
	do
		echo " Copying to folder_$r"
		for (( b=0; b < limit; b++))
		do
			cp copy_testfile "folder_"$r/"copy_test_"$b
		done
		echo " Done with 'folder_$r' at $(date +%I:%M:%S:%N)"
	done
	today=$(date)
	echo " Test ended at '$today'"
	}


function copy_test_3(){
	echo "---------------------------------------------------------"
	echo " Third test, copying of a created file of 8.0 KiB lenght"
	echo " The test will run for $limit times"
	for (( r = 0; r < limit; r++))
	do
		echo " Copying to folder_$r"
		for (( b=0; b < limit; b++))
		do
			cp copy_testfile1 "folder_"$r/"copy_test1_"$b
		done
		echo " Done with 'folder_$r' at $(date +%I:%M:%S:%N)"
	done
	today=$(date)
	echo " Test ended at '$today'"
}

function copy_test_4(){
	echo "---------------------------------------------------------"
	echo " Fourth test, copying of a created file of 16.0 KiB lenght"
	echo " The test will run for $limit times"
	for (( r = 0; r < limit; r++))
	do
		echo " Copying to folder_$r"
		for (( b=0; b < limit; b++))
		do
			cp copy_testfile2 "folder_"$r/"copy_test2_"$b
		done
		echo " Done with 'folder_$r' at $(date +%I:%M:%S:%N)"
	done
	today=$(date)
	echo " Test ended at '$today'"
}

function copy_test_5(){
	echo "---------------------------------------------------------"
	echo " Fifth test, copying of a created file of 32.0 KiB lenght"
	echo " The test will run for $limit times"
	for (( r = 0; r < limit; r++))
	do
		echo " Copying to folder_$r"
		for (( b=0; b < limit; b++))
		do
			cp copy_testfile3 "folder_"$r/"copy_test3_"$b
		done
		echo " Done with 'folder_$r' at $(date +%I:%M:%S:%N)"
	done
	today=$(date)
	echo " Test ended at '$today'"
}

function copy_test_6(){
	echo "---------------------------------------------------------"
	echo " Sixth test, copying of a created file of 256.0 KiB lenght"
	echo " The test will run for $limit times"
	for (( r = 0; r < limit; r++))
	do
		echo " Copying to folder_$r"
		for (( b=0; b < limit; b++))
		do
			cp copy_testfile4 "folder_"$r/"copy_test4_"$b
		done
		echo " Done with 'folder_$r' at $(date +%I:%M:%S:%N)"
	done
	today=$(date)
	echo " Test ended at '$today'"
}
clear

while true; do
	PCT=17
	exec 3>&1
	selection=$(dialog \
		--backtitle "Copy test for Storage Units ver. $filler_version" \
		--title "Main Menu" \
		--clear \
		--cancel-label "Exit" \
		--menu "Choose how long the test will last :" $HEIGHT $WIDTH 4 \
		"1" "32 iterations" \
		"2" "64 iterations" \
		"3" "128 iterations" \
		"4" "256 iterations" \
		2>&1 1>&3)
	exit_status=$?
	exec 3>&-
	case $exit_status in
		$DIALOG_CANCEL)
			clear
			[ -f $OUTPUT ] && rm $OUTPUT
			[ -f $TMPFILE ] && rm $TMPFILE
			echo "Program terminated."
			exit
		;;
		$DIALOG_ESC)
			clear
			[ -f $OUTPUT ] && rm $OUTPUT
			[ -f $TMPFILE ] && rm $TMPFILE
			echo "Program aborted." >&2
			exit 1
		;;
	esac
	case $selection in
		0 )
			clear
			echo "Program terminated 1."
		;;
		1 )
			limit=32
		;;
		2 )
			limit=64
		;;
		3 )
			limit=128
		;;
		4 )
			limit=256
		;;
	esac
		(
		copy_test_1 >> $OUTPUT
		PCT=`expr $PCT + 10`
		echo $PCT
		testprogress=" Test 1 ended "
		copy_test_2 >> $OUTPUT
		PCT=`expr $PCT + 10`
		copy_test_3 >> $OUTPUT
		PCT=`expr $PCT + 10`
		echo $PCT
		copy_test_4 >> $OUTPUT
		PCT=`expr $PCT + 10`
		copy_test_5 >> $OUTPUT
		PCT=`expr $PCT + 10`
		echo $PCT
		copy_test_6 >> $OUTPUT
		PCT=`expr $PCT + 10`
		echo $PCT
		) | dialog --title "Test progress" --gauge "Please wait while test ends..." 20 60 0
		cat $OUTPUT | expand >> $TMPFILE
		dialog --backtitle "Sequential Byte Copy test" --title "Results" --textbox "$TMPFILE" $RHEIGHT $RWIDTH
done


#set -x
# if temp files found, delete em
[ -f $OUTPUT ] && rm $OUTPUT
[ -f $TMPFILE ] && rm $TMPFILE
#set +x
exit

