#!bin/bash
# File          : system-info.sh
# Purpose       : Gather as much system info as possible
# Description   : Script will try to get as much system data as posible and save
#                 it a single location where user can pick and seek for whatever
#                 is required
# Version       : 0.0.2
# Date          : 05-03-2018
# Created by    : Carlos Herrera.
# Notes         : To run type sh system-info.sh in a system terminal with root access.
#                 If modified, please contact the autor to add and check the changes
# Scope         : Generic linux info gathering script, works good on red hat 7.5

# Fun times on errors!
set +x
# set otherwise for fun !!!


# Setting some vars to use :

#Script related
currenthost=$(cat /etc/hostname)
LogDir=SUT_Info_$(date +%Y_%m_%d_%H_%M_%S)
logfile=scriptlog.txt
version="0.0.2"
errorlog=errors.txt
#script folders
hwdir=hw_logs
osdir=os_logs
netdir=net_logs

#seting some functions
function pause(){
	echo "Press the Enter key to continue..."
	read -p "$*"
}

# Prototype
function RunandLog() {
	echo "-------------------------"
	echo "Running $1 "
	$1 $2 >> $LogDir/$3/$4
	echo "Done"
}


# Detecting OS and Distrotype
arch=$(uname -m)
kernel=$(uname -r)
if [ -n "$(command -v lsb_release)" ]; then
	distroname=$(lsb_release -s -d)
elif [ -f "/etc/os-release" ]; then
	distroname=$(grep PRETTY_NAME /etc/os-release | sed 's/PRETTY_NAME=//g' | tr -d '="')
	distroshortname=$(grep PRETTY_NAME /etc/os-release | sed 's/PRETTY_NAME=//g' | sed 's/["]//g' | awk '{print $1}')
elif [ -f "/etc/debian_version" ]; then
	distroname="Debian $(cat /etc/debian_version)"
elif [ -f "/etc/redhat-release" ]; then
	distroname=$(cat /etc/redhat-release)
else
	distroname="$(uname -s) $(uname -r)"
fi

case ${distroshortname} in
	"Red" )
	distrovar=RED_HAT
	;;
	"Ubuntu" )
	distrovar=UBUNTU
	;;
	"SUSE" )
	distrovar=SUSE
	;;	
esac

case $(uname) in 
	Linux )
	if  [ -x "$(command -v yum)" ]; then
		distrotype=RED_HAT_LIKE
	fi
	
	if  [ -x "$(command -v zypper)" ]; then
		distrotype=SUSE_LIKE
	fi
	
	if  [ -x "$(command -v apt-get)" ]; then
		distrotype=DEBIAN_LIKE
	fi
	;;
	
	MacOS )
	#nothing here
	;;
	
	* )
	# Nothing here
	;;
esac



# Setting for a future checkup
if  [ $# -ne 0 ]
then
	echo "Tool to gather Linux OS information for testing cases or debug triage"
	echo " Usage : $0"
	echo "Type : $0 with more than one argument to get this help."
	exit 1
fi

#Start here :
# Get rid of all the term clutter
clear
# A nice introduction ....
echo -e "-----------------------------------------------------------"
echo -e "Running system gathering script for Linux (generic script) on :"
echo "OS : ${distroname} Arch : ${arch} Kernel : ${kernel}"
echo "Distrotype ${distrotype}"
date
echo "Script version : $version"
# Make our new logging directory
if  [ -d "$LogDir" ]
then
	echo "$LogDir directory exists, will continue"
	touch $LogDir/$logfile
	date >> $LogDir/$logfile
else
	echo "$LogDir directory not found, creating one"
	mkdir $LogDir
	touch $LogDir/executed_time.log
	echo "Current username : $(whoami)" >> $LogDir/$logfile
	echo "Logged as        : $(logname)" >> $LogDir/$logfile
	echo "Hostname  is     : $currenthost" >> $LogDir/$logfile
	echo "Starup time : " >> $LogDir/$logfile
	date >> $LogDir/$logfile
fi

mkdir hw_logs
mkdir os_logs
mkdir net_logs



if [ -d  "/bin" ]
then 
	echo "main directory BIN is present continue ..."
else
	echo "BIN directory is not present at // bailing out..."
	exit 1
fi


# Annnnd proceed with the script ...
echo " Starting the recolletion " >> $LogDir/$logfile
echo " Process started at $(date +%Y_%m_%d_%H_%M_%S) " >> $LogDir/$logfile


#Hardware collecting routines


if [ -x "$(command -v lshw)" ]; then 
	echo "Running LSHW"
	echo "lshw running " >> $LogDir/$logfile
	lshw -html > $LogDir/$hw_logs/lshw-system-info.html
	lshw -short >$LogDir/$hw_logs/lshw-system-info-brief.log
fi

if [ -x "$(command -v hwinfo)" ]; then 
	echo "Running (HWINFO) : System information, please wait"
	hwinfo --all --log=$LogDir/$hw_logs/hwinfo-log.txt
fi

if [ -x "$(command -v dmidecode)" ]; then 
	echo "Running DMIDECODE "
	echo "dmidecode running" >> $LogDir/$logfile	
	dmidecode > $LogDir/$hw_logs/dmidecode-system-dmi-full-hw.log
fi

if [ -x "$(command -v lspci)" ]; then 
	echo "Running LSPCI "
	echo "lspci running" >> $LogDir/$logfile	
	echo "Running (LSCPI) : PCI devices info"
	lspci -t -vmm > $LogDir/$hw_logs/lspci-pci-devices-topology-verbose.log
fi

if [ -x "$(command -v lscpu)" ]; then 
	echo "Running LSCPU "
	echo "lspcpu running" >> $LogDir/$logfile	
	lscpu > $LogDir/lscpu-cpu-basic.log
	lscpu --extended --all | column -t > $LogDir/$hw_logs/lscpu-cpu-extended.log
fi 


if [ -f /proc/cpuinfo  ]; then 
	echo "Getting CPU data "
	echo "CPUINFO collected" >> $LogDir/$logfile	
	echo "Getting CPU Information"
	cat /proc/cpuinfo > $LogDir/$hw_logs/cpuinfo.log
fi




#disk info section
echo "Running (LSBLK) : Block devices info."
lsblk --all --ascii --perms --fs > $LogDir/lsblk-block-devices.log



echo "Running (LSUSB) : USB info."
lsusb -t > $LogDir/lsusb-usb-devices-topology.log
lsusb > $LogDir/lsusb-usb-devices-normal.log


echo "Running (LSSCSI) : SCSI devices."
lsscsi --size --verbose | column -t > $LogDir/lsssci-scsi-devices-verbose.log

echo "Running (FDISK) : Filesystem info."
fdisk -l > $LogDir/fdisk-fs-sys.log


echo "Running (DF) : Disk usage stats"
df -h > $LogDir/df-disk-usage.log

echo "Runnig (MOUNT) : Mounted stats."
mount | column -t > $LogDir/mounted-devices.log


echo "Running (FREE) : Memory stats."
free -m > $LogDir/free-memory-usage.log
cat /proc/meminfo > $LogDir/proc-meminfo-memory-assigned.log


echo "Running (LSMOD) : Module information"
lsmod | column -t > $LogDir/lsmod-modules-loaded.log


echo "Running (DMESG) : Getting DMESG info."
dmesg > $LogDir/dmesg.log
dmesg --level=warn > $LogDir/dmesg-warnings.log
dmesg --level=err > $LogDir/dmesg-errors.log


echo "Power Mgnt : Getting C-States and Scalign driver info"
echo "CPU idle current driver :" > $LogDir/pwr-cstates-driver.log
cat /sys/devices/system/cpu/cpuidle/current_driver >> $LogDir/pwr-cstates-driver.log
echo "CPU Scaling driver :" >> $LogDir/pwr-cstates-driver.log
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_driver >> $LogDir/pwr-cstates-driver.log


echo "OS  : System version :"
cat /proc/version > $LogDir/proc-system-version.log
echo "-----------------------------------------------------------"
echo "OS : Getting all system messages"
cat /var/log/messages > $LogDir/messages.log
echo "-----------------------------------------------------------"
echo "OS : Getting SoftIRQs info"
cat /proc/softirqs > $LogDir/softirqs.log
echo "-----------------------------------------------------------"
echo "OS : Gettimg modules information "
cat /proc/modules | column -t > $LogDir/modules.log
echo "-----------------------------------------------------------"
echo "OS : Getting IO-Memory assignation"
cat /proc/iomem > $LogDir/iomem.log
echo "-----------------------------------------------------------"
echo "OS : Getting Partitions assignation"
cat /proc/partitions > $LogDir/partitions.log



echo "-----------------------------------------------------------"
echo "OS : Getting Memory page information"
cat /proc/pagetypeinfo > $LogDir/pagetypeinfo.log
echo "-----------------------------------------------------------"
echo "OS : Getting Network devices stats"
cat /proc/net/dev | column -t > $LogDir/network_devices_stats.log
echo "-----------------------------------------------------------"
echo "OS : Linux boot command line :"
cat /proc/cmdline > $LogDir/linux_os_boot_line.log
echo "-----------------------------------------------------------"
echo "OS : Crytograhpy on OS :"
cat /proc/crypto > $LogDir/linux_os_cryto.log
echo "-----------------------------------------------------------"
echo "OS : Disk stats"
cat /proc/diskstats | column -t > $LogDir/linux_diskstats.log
echo "-----------------------------------------------------------"

echo "Script is done, you may want to check the logs on ${LogDir} "
echo "End time : " >> $LogDir/executed_time.log
date  >> $LogDir/executed_time.log