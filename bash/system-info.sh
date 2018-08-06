#!bin/bash
# File          : system-info.sh
# Purpose       : Gather as much system info as possible
# Description   : Script will try to get as much system data as posible and save
#                 it a single location where user can pick and seek for whatever
#                 is required
# Version       : 0.0.1

LogDir=SUT_Info

# Setting for a future checkup
set +x

if  [ $# -ne 0 ]
then
	echo " Usage : $0"
	exit 1
fi

# Get rid of all the term clutter
clear
# A nice introduction ....
echo -e "-----------------------------------------------------------"
echo -e " Running system gathering scrip for Linux (generic script) on :"
date
uname 
uname -r
uname -m
# Make our new logging directory
if  [ -d "$LogDir" ]
then
	echo "$LogDir directory exists, will continue"
	touch first.log
	date >> first.log
else
	echo "$LogDir directory not found, creating one"
	mkdir $LogDir
	touch first.log
	date >> first.log
fi

if [ -d  "/bin" ]
then 
	echo "main directory BIN is present continue ..."
else
	echo "BIN directory is not present at // bailing out..."
	exit 1
fi

# And proceed with the script ...
echo "-----------------------------------------------------------"
echo "Running : System hardware information full & short"
lshw -html > $LogDir/system-info.html
lshw -short > $LogDir/system-info-brief.log
dmidecode > $LogDir/system-dmi-full-hw.log
echo "-----------------------------------------------------------"
echo "Running : CPU basic & extended info."
lscpu > $LogDir/cpu-basic.log
lscpu --extended --all > $LogDir/cpu-extended.log
echo "-----------------------------------------------------------"
echo "Running : Block devices info."
lsblk --all --ascii --perms --fs > $LogDir/block-devices.log
echo "-----------------------------------------------------------"
echo "Running : PCI devices info"
lspci -t -vmm > $LogDir/pci-devices.log
echo "-----------------------------------------------------------"
echo "Running : USB info."
lsusb -t > $LogDir/usb-devices.log
lsusb > $LogDir/usb-devices-normal.log
echo "-----------------------------------------------------------"
echo "Running : SCSI devices."
lsscsi --size --verbose > $LogDir/scsi-devices.log
echo "-----------------------------------------------------------"
echo "Running : Filesystem info."
fdisk -l -s > $LogDir/fs-sys.log
echo "-----------------------------------------------------------"
echo "Running : Disk usage stats."
df -h > $LogDir/disk-usage.log
echo "-----------------------------------------------------------"
echo "Runnig : Mounted stats."
mount | column -t > $LogDir/mounted-devices.log
echo "-----------------------------------------------------------"
echo "Running : Memory stats."
free -m > $LogDir/memory-usage.log
cat /proc/meminfo > $LogDir/memory-assigned.log
echo "-----------------------------------------------------------"
echo "Running : System version :"
cat /proc/version > $LogDir/system-version.log
echo "-----------------------------------------------------------"
echo "Running : Module information"
lsmod | column -t > $LogDir/modules-loaded.log
echo "-----------------------------------------------------------"
echo "Script is done, you may want to check the logs on ${LogDir} "




