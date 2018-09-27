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
currenthost=$(cat /etc/hostname)
LogDir=SUT_Info_$(date +%Y_%m_%d_%H_%M_%S)
version="0.0.2"

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
		distrotype=RED_HAT
	fi
	
	if  [ -x "$(command -v zypper)" ]; then
		distrotype=SUSE
	fi
	
	if  [ -x "$(command -v apt-get)" ]; then
		distrotype=DEBIAN
	fi
	
	#which yum && { distrotype=RED_HAT;  }
	#which zypper && { distrotype=SUSE;  }
	#which apt-get && { distrotype=DEBIAN; }
	;;
	* )
	# Nothing here
	;;
esac



# Setting for a future checkup
if  [ $# -ne 0 ]
then
	echo " Usage : $0"
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
	touch $LogDir/first.log
	date >> $LogDir/first.log
else
	echo "$LogDir directory not found, creating one"
	mkdir $LogDir
	touch $LogDir/executed_time.log
	echo "Current username : $(whoami)" >> $LogDir/executed_time.log
	echo "Logged as        : $(logname)" >> $LogDir/executed_time.log
	echo "Hostname  is     : $currenthost" >> $LogDir/executed_time.log
	echo "Starup time : " >> $LogDir/executed_time.log
	date >> $LogDir/executed_time.log
fi

if [ -d  "/bin" ]
then 
	echo "main directory BIN is present continue ..."
else
	echo "BIN directory is not present at // bailing out..."
	exit 1
fi


# Annnnd proceed with the script ...
echo "-----------------------------------------------------------"
if [ -x "$(command -v lshw)" ]; then 
	echo "Running (LSHW) : System information, please wait"
	lshw -html > $LogDir/lshw-system-info.html
	lshw -short > $LogDir/lshw-system-info-brief.log
fi

if [ -x "$(command -v hwinfo)" ]; then 
	echo "Running (HWINFO) : System information, please wait"
	hwinfo --all --log=$LogDir/hwinfo-log.txt
fi
echo "Running (DMIDECODE) : Full System hardware information"
dmidecode > $LogDir/dmidecode-system-dmi-full-hw.log
echo "-----------------------------------------------------------"
echo "Running (LSCPU) : CPU basic & extended info."
lscpu > $LogDir/lscpu-cpu-basic.log
lscpu --extended --all | column -t > $LogDir/lscpu-cpu-extended.log
echo "-----------------------------------------------------------"
echo "Running (LSBLK) : Block devices info."
lsblk --all --ascii --perms --fs > $LogDir/lsblk-block-devices.log
echo "-----------------------------------------------------------"
echo "Running (LSCPI) : PCI devices info"
lspci -t -vmm > $LogDir/lspci-pci-devices-topology-verbose.log
echo "-----------------------------------------------------------"
echo "Running (LSUSB) : USB info."
lsusb -t > $LogDir/lsusb-usb-devices-topology.log
lsusb > $LogDir/lsusb-usb-devices-normal.log
echo "-----------------------------------------------------------"
echo "Running (LSSCSI) : SCSI devices."
lsscsi --size --verbose | column -t > $LogDir/lsssci-scsi-devices-verbose.log
echo "-----------------------------------------------------------"
echo "Running (FDISK) : Filesystem info."
fdisk -l > $LogDir/fdisk-fs-sys.log
echo "-----------------------------------------------------------"
echo "Running (DF) : Disk usage stats"
df -h > $LogDir/df-disk-usage.log
echo "-----------------------------------------------------------"
echo "Runnig (MOUNT) : Mounted stats."
mount | column -t > $LogDir/mounted-devices.log
echo "-----------------------------------------------------------"
echo "Running (FREE) : Memory stats."
free -m > $LogDir/free-memory-usage.log
cat /proc/meminfo > $LogDir/proc-meminfo-memory-assigned.log
echo "-----------------------------------------------------------"
echo "Running (LSMOD) : Module information"
lsmod | column -t > $LogDir/lsmod-modules-loaded.log
echo "-----------------------------------------------------------"
echo "Running (DMESG) : Getting DMESG info."
dmesg > $LogDir/dmesg.log
dmesg --level=warn > $LogDir/dmesg-warnings.log
dmesg --level=err > $LogDir/dmesg-errors.log
echo "-----------------------------------------------------------"
echo "Power Mgnt : Getting C-States and Scalign driver info"
echo "CPU idle current driver :" > $LogDir/pwr-cstates-driver.log
cat /sys/devices/system/cpu/cpuidle/current_driver >> $LogDir/pwr-cstates-driver.log
echo "CPU Scaling driver :" >> $LogDir/pwr-cstates-driver.log
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_driver >> $LogDir/pwr-cstates-driver.log
echo "-----------------------------------------------------------"
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
echo "OS : Getting CPU Information"
cat /proc/cpuinfo > $LogDir/cpuinfo.log
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

