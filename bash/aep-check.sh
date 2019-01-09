#!/bin/bash
# File          : aep-check shell script
# Purpose       : Get SCPMM memory module info
# Description   : Gather and create logs about memory modules 
# Version       : 0.0.2
# Date          : 11-7-2018
# Created by    : Carlos Herrera.
# Notes         : 
#                 If modified, please contact the autor to add and check the changes
# Scope         : Generic linux info gathering script, works good on red hat 7.5
#               : Do not remove this header, thanks!


#var setup
main_folder=dcpmm
report_folder=report_$(date +%Y_%m_%d_%H_%M_%S)
dcpmm_log_health=dimm_mem_health_report.txt
dcpmm_log_fw=dimm_mem_fw_report.txt
dcpmm_log_mem_alloc=dimm_mem_alloc.txt
dcpmm_log_mem_cfg=dimm_mem_cfg.txt
dcpmm_log_namespaces=dimm_mem_namespaces.txt
dcpmm_log_regions=dimm_mem_regions.txt

function AEPHealthReport() 
{
	echo "=================================================="
	echo "[Health.check]"
	echo "Executed on $(date +%Y:%m:%d:%H:%M:%S) "

	echo "- Show Device"
	ipmctl show -dimm

	echo "- Show Device; Attribute BootStatus"
	ipmctl show -d LastShutdownStatus -dimm

	echo "- Show Topology"
	ipmctl show -topology

	echo "- Show Memory Resources"
	ipmctl show -memoryresources

	echo "-Show System Capabilities"
	ipmctl show -system -capabilities

	echo "-Show Sensor (Media Temperature)"
	ipmctl show -Sensor

	echo "-More heatlh check"
	ipmctl show -d HealthState,ManageabilityState,FWVersion -dimm

	echo "-Show Device - Attribute BootStatus "
	ipmctl show -d bootstatus -dimm 
	
	echo "-Show modes supported"
	ipmctl show -d modessupported -system -capabilities
}

function AEPFirmwareCheck() 
{
	echo "=================================================="
	echo "[Firmware]"
	echo "Executed on $(date +%Y:%m:%d:%H:%M:%S) "

	echo "-Show firmware"
	ipmctl show -dimm -firmware
}

function AEPConfigSave() 
{
	echo "=================================================="
	echo "[Save current Memory Config]"
	echo "Executed on $(date +%Y:%m:%d:%H:%M:%S) "

	echo "-Store the currently configured memory allocation settings for all DCPMMs"
	ipmctl dump -destination config.csv -system -config
}


function AEPMemAllocation () 
{
	echo "=================================================="
	echo "[Memory-allocation]"
	echo "Executed $(date +%Y:%m:%d:%H:%M:%S) "

	echo "-Save the memory allocation goal on one or more DCPMMs"
	ipmctl show -goal
}

function AEPNameSpaces() 
{
	echo "=================================================="
	echo "[Memory-namespaces (if any)]"
	echo "Executed $(date +%Y:%m:%d:%H:%M:%S) "
	
	ndctl list --namespaces
}

function AEPShowAllRegions() 
{
	echo "=================================================="
	echo "[Memory-Show all regions (if any)]"
	echo "Executed $(date +%Y:%m:%d:%H:%M:%S) "
	
	ndctl list --region=all
	
}

kbin=-1

if [ ! -x "$(command -v ipmctl)" ]; then 
	echo "ipmctl commmand not found. Will not continue. check your installation"
	exit 1
fi 

if [ ! -x "$(command -v ndctl)" ]; then 
	echo "ndctl command not found. Will not continue. Check your installation"
	exit 1
fi

clear

while [ $kbin -ne 0 ]
do 
	echo "Select one of below"
	echo "1- DCPMM Dimmm module HealthReport"
	echo "2- DCPMM Dimmm module check firmware"
	echo "3- DCPMM Dimmm module Memory Allocation"
	echo "4- DCPMM Dimmm module save Current configuration"
	echo "5- DCPMM Dimmm module show NameSpaces"
	echo "6- DCPMM Dimmm module Show AllRegions"
	echo "7 Run all."
	echo "0 Quit."

	read -p "Type your choice :" kbin

	case $kbin in
		1)
			AEPHealthReport | tee -a $dcpmm_log_health
		;;
		2)
			AEPFirmwareCheck | tee -a $dcpmm_log_fw
		;;
		3)
			AEPMemAllocation | tee -a $dcpmm_log_mem_alloc
		;;
		4)
			AEPConfigSave | tee -a $dcpmm_log_mem_cfg
		;;
		5) 
			AEPNameSpaces | tee -a $dcpmm_log_namespaces
		;;
		6) 
			AEPShowAllRegions | tee -a $dcpmm_log_regions
		;;
		7)
			AEPHealthReport | tee -a $dcpmm_log_health
			AEPFirmwareCheck | tee -a $dcpmm_log_fw
			AEPMemAllocation | tee -a $dcpmm_log_mem_alloc
			AEPConfigSave | tee -a $dcpmm_log_mem_cfg
			AEPNameSpaces | tee -a $dcpmm_log_namespaces
			AEPShowAllRegions | tee -a $dcpmm_log_regions
		;;
		*)
		echo "Not an option"

	esac

done
echo "Done"
exit

