#!/bin/bash
# 	File          : filler_01.sh
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
clear
today=$(date)
host=$(hostname)
linuxver=$(uname -r)
datatofile="1010101010101010101010101010101"
filler_version=0.0.2
limit=0
echo "-----------------------------------------------------------------"
echo " Simple test for the filesystem ver. $filler_version"
echo " This script is running on the host : $host"
echo " System kernel is : $linuxver"
echo " A higher number, more time will be required; Try to not use your device"
echo " while this test is running"
echo " Choose how long the test will last : "
echo " 1- 32"
echo " 2- 64"
echo " 3- 128"
echo " 4- 256"
echo " 5- Quit"
read -p " > " user_opt
case $user_opt in
	1)
		limit=32
	;;
	2)
		limit=64
	;;
	3)
		limit=128
	;;
	4)
		limit=256
	;;
	5)
		exit
	;;
	*)
		limit=16
	;;
esac
clear
echo " This test started at : $(date +%D,%I:%M:%S)"
echo " First test , write multiple files using a fixed 32 character line"
for (( i=0; i <limit; i++))
do
	echo "---------------------------------------------------------"
	echo " Creating folder 'folder_$i'"
	mkdir "folder_"$i
	cd "folder_"$i
	for (( b= 0; b < limit; b++))
	do
		touch "file_"$b
		#echo " File 'file_$b' was created"
		for (( f=0; f < 128; f++))
		do
			echo $datatofile >> "file_"$b
		done
		#printf "File created at %s" $(date)
		#echo "File 'file$b' was created inside $(pwd)"
	done
	echo " Done with 'folder_$i' at $(date +%I:%M:%S:%N)"
	cd ..
done

today=$(date)
echo " Test ended at $(date +%D,%I:%M:%S)"
clear
echo "---------------------------------------------------------"
echo " Second test, copying of a created file of 4.0 KiB lenght"
echo " This test started at : $(date +%D,%I:%M:%S)"
for (( r = 0; r < limit; r++))
do
	echo "---------------------------------------------------------"
	echo " Copying to folder_$r"
	for (( b=0; b < limit; b++))
	do
		cp copy_testfile "folder_"$r/"copy_test_"$b
	done
	echo " Done with 'folder_$r' at $(date +%I:%M:%S:%N)"
done
echo " Test ended at $(date)"
#
clear
echo "---------------------------------------------------------"
echo " Third test, copying of a created file of 8.0 KiB lenght"
echo " This test started at : $(date +%D,%I:%M:%S)"
for (( r = 0; r < limit; r++))
do
	echo "---------------------------------------------------------"
	echo " Copying to folder_$r"
	for (( b=0; b < limit; b++))
	do
		cp copy_testfile1 "folder_"$r/"copy_test1_"$b
	done
	echo " Done with 'folder_$r' at $(date +%I:%M:%S:%N)"
done
echo " Test ended at $(date +%D,%I:%M:%S)"
#
clear
echo "---------------------------------------------------------"
echo " Third test, copying of a created file of 16.0 KiB lenght"
echo " This test started at : $(date +%D,%I:%M:%S)"
for (( r = 0; r < limit; r++))
do
	echo "---------------------------------------------------------"
	echo " Copying to folder_$r"
	for (( b=0; b < limit; b++))
	do
		cp copy_testfile2 "folder_"$r/"copy_test2_"$b
	done
	echo " Done with 'folder_$r' at $(date +%I:%M:%S:%N)"
done
today=$(date)
echo " Test ended at $(date +%D,%I:%M:%S)"
#
clear
echo "---------------------------------------------------------"
echo " Third test, copying of a created file of 32.0 KiB lenght"
echo " This test started at : $(date +%D,%I:%M:%S)"
for (( r = 0; r < limit; r++))
do
	echo "---------------------------------------------------------"
	echo " Copying to folder_$r"
	for (( b=0; b < limit; b++))
	do
		cp copy_testfile3 "folder_"$r/"copy_test3_"$b
	done
	echo " Done with 'folder_$r' at $(date +%I:%M:%S:%N)"
done
today=$(date)
echo " Test ended at $(date +%D,%I:%M:%S)"
clear
echo "---------------------------------------------------------"
echo " Third test, copying of a created file of 256.0 KiB lenght"
echo " This test started at : $(date +%D,%I:%M:%S)"
for (( r = 0; r < limit; r++))
do
	echo "---------------------------------------------------------"
	echo " Copying to folder_$r"
	for (( b=0; b < limit; b++))
	do
		cp copy_testfile4 "folder_"$r/"copy_test4_"$b
	done
	echo " Done with 'folder_$r' at $(date +%I:%M:%S:%N)"
done
today=$(date)
echo " Test ended at $(date +%D,%I:%M:%S)"
exit
