#!/bin/bash
# File          : system-info.sh
# Purpose       : Gather as much system info as possible
# Description   : Script will try to get as much system data as posible and save
#                 it a single location where user can pick and seek for whatever
#                 is required
# Version       : 0.1.12
# Date          : 2018-11-18-21:18 -2018-12-25 22:51
# Created by    : Carlos Herrera.
# Notes         : To run type sh system-info.sh in a system terminal with root access.
#                 If modified, please contact the autor to add and check the changes
# Scope         : Generic linux info gathering script, tested on RHEL 7.5, 8.0 beta, SUSE15
#               : Do not remove this header, thanks!

# Fun times on errors!
set +x
# set otherwise on for fun !!!

# Setting some vars to use :

#Script related
arch=-1
kernel=-1
distroname=1
distroshortname=1
distrovar=1
distrotype=1
extension=.txt
currenthost=$(cat /etc/hostname)
main_folder=systeminfo
LogDir=sut_info_$(date +%Y_%m_%d_%H_%M_%S)
logfile=summary.txt
version="0.1.11"
errorlog=$main_folder/$LogDir/errors.txt
htmllog=$main_folder/$LogDir/log_summary.html

#script folders
hw_dir=hw
os_dir=os
net_dir=net
power_dir=power
storage_dir=storage
io_dir=io
memory_dir=memory
modules_dir=modules


#Pause function
function pause(){
	echo "Press the Enter key to continue..."
	read -p "$*"
}

# Prototype 1 command 2 arguments (opt) 3 path to save 4 log filename
function RunCmdandLog() {
	if [ -n "$(command -v $1)" ]; then
		echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $1 ] "
		echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $1 ] " >> $3/$4
		$1 $2 >> $3/$4
		echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $1 ] " >> $3/$4
	fi
}

function logHTMLHeader() {
	echo "<html> <head> </head> <body> <h4>Summary of log recolletion </h4> <pre> " >> $htmllog
	systembanner >> $htmllog
	echo "</pre> <table widht=90%>" >> $htmllog
}

function logHTMLFooter() { 
	echo "</table> <p> Script done.</p> <p>Version ${version} Date : $(date +%Y:%m:%d:%H:%M:%S) </p></body> </html>" >> $htmllog
}

# $1 text log , $2 is text string
function logHeader() {
	#to screen
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $2  ] "
	#to log
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $2  ] " >> $1  
	echo "<tr><td> $2  </td></tr>" >> $htmllog
}

# $1 text log
function logFooter() {
	#to screen
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $2 ] "
	#to log
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $2 ] " >> $1  
	echo "<tr><td> $2  </td> <td> saved in folder $3 </td> </tr>" >> $htmllog
}

# $1 text log, $2 target dir, # $3 text, $4 target dir
function logFileStubbSection() {
	echo $3
	echo $3 >> $1
	echo "--Files for this section  are :" >> $1
	echo "-----------------------------------------" >> $1
	echo "$(ls $2)"  >> $1
	echo "-----------------------------------------" >> $1
	echo "<tr><td> <p> Files </p></td> <td>" >> $htmllog 
	for fn in $(ls $2) ; do echo "<a href=./$4/${fn}> ${fn} </a> <br>" >> $htmllog ; done
	echo " </td> </tr>" >> $htmllog
 }

#System info banner
function systembanner() {
	echo "************************************************************"
	echo "System Report for $(cat /etc/hostname) ($(hostname -I | awk '{print $1}'))"
	echo "Generated at $(date)"
	echo "************************************************************"
	echo " Uptime:         $(uptime)"
	echo " Kernel Version: $(uname -r)"
	echo " Load info:      $(cat /proc/loadavg)"
	echo " Disk status:    $(df -h / | awk 'FNR == 2 {print $5 " used (" $4 " free)"}')"
	echo " Memory status:  $(free -h | awk 'FNR == 2 {print $3 " used (" $4 " free)"}')"
	echo " OS : ${distroname} "
	echo " Arch : ${arch}"
	echo " Kernel : ${kernel}"
	echo " Distrotype : ${distrotype}"
	echo " Runlevel : $(runlevel)"
	echo " Script version : ${version}"
}

# Detecting OS and Distrotype
function OS_detect() {
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
}

#Main folders setup
function folderSetup(){
	mkdir --parents $main_folder/$LogDir/$hw_dir
	mkdir --parents $main_folder/$LogDir/$os_dir
	mkdir --parents $main_folder/$LogDir/$os_dir/etc/
	mkdir --parents $main_folder/$LogDir/$net_dir
	mkdir --parents $main_folder/$LogDir/$power_dir
	mkdir --parents $main_folder/$LogDir/$storage_dir
	mkdir --parents $main_folder/$LogDir/$memory_dir
	mkdir --parents $main_folder/$LogDir/$modules_dir
	mkdir --parents $main_folder/$LogDir/$io_dir
}


# Setting for a future command line checkup
if  [ $# -ne 0 ]
then
	echo "Tool to gather Linux OS information for testing cases or debug triage"
	echo " Usage : $0"
	echo "Type : $0 with more than one argument to get this help."
	exit 1
fi

#Start here :

#Linux distro detection
OS_detect
# Make our new logging directory
if  [ -d "$main_folder/$LogDir" ]
then
	echo "$main_folder/$LogDir directory exists, will continue"
	touch $main_folder/$LogDir/$logfile
	systembanner >> $main_folder/$LogDir/$logfile
	echo "" >> $main_folder/$LogDir/$logfile
	date >> $main_folder/$LogDir/$logfile
	# Create folder for logs
	folderSetup
else
	echo "$main_folder/$LogDir directory not found, creating one"
	mkdir $main_folder/$LogDir
	touch $main_folder/$LogDir/$logfile
	systembanner >> $main_folder/$LogDir/$logfile
	echo "" >> $main_folder/$LogDir/$logfile
	# Create folder for logs
	date >> $main_folder/$LogDir/$logfile
	folderSetup
fi

# Checking this does not hurt
if [ -d  "/bin" ]
then 
	echo "main directory BIN is present continue ..." >> $main_folder/$LogDir/$logfile
else
	echo "BIN directory is not present at // bailing out..." >> $main_folder/$LogDir/$errorlog
	exit 1
fi

# Get rid of all the term clutter
clear

# A nice introduction ....
systembanner

# Annnnd proceed with the script ...

echo "- Starting the recolletion " >> $main_folder/$LogDir/$logfile
echo "- Process started at $(date +%Y:%m:%d:%H:%M:%S) " >> $main_folder/$LogDir/$logfile

logHTMLHeader

# Hardware logs section
echo "- Hardware section starts :" >> $main_folder/$LogDir/$logfile

if [ -x "$(command -v lshw)" ]; then 
	logHeader $main_folder/$LogDir/$logfile "hardware : lshw"
	lshw -html > $main_folder/$LogDir/$hw_dir/lshw-system-info.html
	lshw -short >$main_folder/$LogDir/$hw_dir/lshw-system-info-brief$extension
	logFooter $main_folder/$LogDir/$logfile "-" $main_folder/$LogDir/$hw_dir/
fi

if [ -x "$(command -v hwinfo)" ]; then 
	logHeader $main_folder/$LogDir/$logfile "hardware : hwinfo"
	hwinfo --all --log=$main_folder/$LogDir/$hw_dir/hwinfo$extension
	logFooter $main_folder/$LogDir/$logfile "-" $main_folder/$LogDir/$hw_dir/
fi


if [ -x "$(command -v dmidecode)" ]; then 
	logHeader $main_folder/$LogDir/$logfile "hardware : dmidecode"
	dmidecode > $main_folder/$LogDir/$hw_dir/dmidecode-system-dmi-full-hw$extension
	logFooter $main_folder/$LogDir/$logfile "-" $main_folder/$LogDir/$hw_dir/
fi


if [ -x "$(command -v lspci)" ]; then 
	logHeader $main_folder/$LogDir/$logfile "hardware : lspci"
	lspci -t -vmm > $main_folder/$LogDir/$hw_dir/lspci-pci-devices-topology-verbose$extension
	lspci -vvvxxx > $main_folder/$LogDir/$hw_dir/lspci-pci-devices-extra-verbose$extension
	logFooter $main_folder/$LogDir/$logfile "-" $main_folder/$LogDir/$hw_dir/
fi

if [ -x "$(command -v lscpu)" ]; then 
	logHeader $main_folder/$LogDir/$logfile "hardware : lscpu"
	lscpu > $main_folder/$LogDir/$hw_dir/lscpu-cpu-basic$extension
	lscpu --extended --all | column -t > $main_folder/$LogDir/$hw_dir/lscpu-extended$extension
	logFooter $main_folder/$LogDir/$logfile "-" $main_folder/$LogDir/$hw_dir/
fi 

if [ -f /proc/cpuinfo  ]; then 
	logHeader $main_folder/$LogDir/$logfile "hardware : lspcpu"
	cp /proc/cpuinfo $main_folder/$LogDir/$hw_dir/cpuinfo$extension 2>> $errorlog
	logFooter $main_folder/$LogDir/$logfile "-" $main_folder/$LogDir/$hw_dir/
fi

if [ -f /proc/schedstat ]; then 
	logHeader $main_folder/$LogDir/$logfile "hardware : cpu schedule"
	cp /proc/schedstat $main_folder/$LogDir/$hw_dir/cpu_schedule$extension 2>>$errorlog
	logFooter $main_folder/$LogDir/$logfile "-" $main_folder/$LogDir/$hw_dir/
fi


if [ -f /var/log/xorg.0$extension ]; then 
	logHeader $main_folder/$LogDir/$logfile "hardware : x-server"
	cp /var/log/xorg.0$extension $main_folder/$LogDir/$hw_dir/xorg$extension 2>> $errorlog
	logFooter $main_folder/$LogDir/$logfile "-" $main_folder/$LogDir/$hw_dir/
fi


if [ -f /proc/devices ]; then 
	logHeader $main_folder/$LogDir/$logfile "hardware : devices"
	cp /proc/devices $main_folder/$LogDir/$hw_dir/devices$extension 2>> $errorlog
	logFooter $main_folder/$LogDir/$logfile "-" $main_folder/$LogDir/$hw_dir/
fi

logFileStubbSection $main_folder/$LogDir/$logfile $main_folder/$LogDir/$hw_dir/ "- hardware section end " $hw_dir

# Storage logs section
echo "- Storage section begins " >> $main_folder/$LogDir/$logfile
if [ -f /proc/cpuinfo  ]; then 
	logHeader $main_folder/$LogDir/$logfile "storage : lsblk"
	lsblk --all --ascii --perms --fs > $main_folder/$LogDir/$storage_dir/lsblk$extension
	logFooter $main_folder/$LogDir/$logfile "-" $main_folder/$LogDir/$storage_dir/
fi 

if [ -x "$(command -v lsscsi)" ]; then 
	logHeader $main_folder/$LogDir/$logfile "storage : lsscsi"
	lsscsi --size --verbose | column -t > $main_folder/$LogDir/$storage_dir/lsssci-verbose$extension
	logFooter $main_folder/$LogDir/$logfile "lsscsi" $main_folder/$LogDir/$storage_dir/
fi

if [ -x "$(command -v fdisk)" ]; then 
	logHeader $main_folder/$LogDir/$logfile "storage : fdisk"
	fdisk -l > $main_folder/$LogDir/$storage_dir/fdisk$extension
	logFooter $main_folder/$LogDir/$logfile "-" $main_folder/$LogDir/$storage_dir/
fi

if [ -x "$(command -v df)" ]; then 
	logHeader $main_folder/$LogDir/$logfile "storage : df"
	df -h > $main_folder/$LogDir/$storage_dir/df-usage$extension
	logFooter $main_folder/$LogDir/$logfile "-" $main_folder/$LogDir/$storage_dir/
fi

if [ -f /proc/partitions  ];then 
	logHeader $main_folder/$LogDir/$logfile "storage : partition file"
	cp /proc/partitions $main_folder/$LogDir/$storage_dir/partitions$extension 2>> $errorlog
	logFooter $main_folder/$LogDir/$logfile "-" $main_folder/$LogDir/$storage_dir/
fi

if [ -x "$(command -v mount)" ]; then 
	logHeader $main_folder/$LogDir/$logfile "storage : mount"
	mount | column -t > $main_folder/$LogDir/$storage_dir/mounted_devices$extension
	logFooter $main_folder/$LogDir/$logfile "-" $main_folder/$LogDir/$storage_dir/
fi

if [ -f /proc/scsi  ]; then 
	logHeader $main_folder/$LogDir/$logfile "storage : scsi"
	cp /proc/scsi/scsi $main_folder/$LogDir/$storage_dir/scsi_devices$extension 2>>$errorlog
	logFooter $main_folder/$LogDir/$logfile "-" $main_folder/$LogDir/$storage_dir/
fi

if [ -f /proc/scsi/mounts ]; then 
	logHeader $main_folder/$LogDir/$logfile "storage : scsi-mounts"
	cp /proc/scsi/mounts  $main_folder/$LogDir/$storage_dir/scsi-mounts$extension 2>>$errorlog
	logFooter $main_folder/$LogDir/$logfile "-" $main_folder/$LogDir/$storage_dir/
fi

if [ -f /proc/diskstats ]; then 
	logHeader $main_folder/$LogDir/$logfile "storage : diskstats"
	cat /proc/diskstats | column -t >> $main_folder/$LogDir/$storage_dir/diskstats$extension
	logFooter $main_folder/$LogDir/$logfile "-" $main_folder/$LogDir/$storage_dir/
fi

if [ -f /proc/filesystems ]; then 
	logHeader $main_folder/$LogDir/$logfile "storage : filesystems"
	cp /proc/filesystems  $main_folder/$LogDir/$storage_dir/fs_systems$extension 2>>$errorlog
	logFooter $main_folder/$LogDir/$logfile "-" $main_folder/$LogDir/$storage_dir/
fi


if [ -x "$(command -v blockdev)" ]; then 
	logHeader $main_folder/$LogDir/$logfile "storage : blockdev"
	blockdev --report  >> $main_folder/$LogDir/$storage_dir/blockdevices$extension
	logFooter $main_folder/$LogDir/$logfile "-" $main_folder/$LogDir/$storage_dir/
fi

if [ -x "$(command -v swapon)" ]; then 
	logHeader $main_folder/$LogDir/$logfile "storage : swaps"
	swapon --all >> $main_folder/$LogDir/$storage_dir/swaps$extension
	logFooter $main_folder/$LogDir/$logfile "-" $main_folder/$LogDir/$storage_dir/
fi
logFileStubbSection $main_folder/$LogDir/$logfile $main_folder/$LogDir/$storage_dir/ "- Storage section ends " $storage_dir

#IO section
echo "- IO section begins " >> $main_folder/$LogDir/$logfile

if [ -f /proc/ioports ]; then 
	logHeader $main_folder/$LogDir/$logfile "io : ioports"
	cp /proc/ioports  $main_folder/$LogDir/$io_dir/io_ports$extension 2>>$errorlog
	logFooter $main_folder/$LogDir/$logfile "-" $main_folder/$LogDir/$io_dir
fi 

if [ -x "$(command -v lsusb)" ]; then 
	logHeader $main_folder/$LogDir/$logfile "io : lsusb"
	lsusb -t > $main_folder/$LogDir/$io_dir/lsusb_topology$extension
	lsusb > $main_folder/$LogDir/$io_dir/lsusb_normal$extension
	logFooter $main_folder/$LogDir/$logfile "-" $main_folder/$LogDir/$io_dir
fi

if [ -f /proc/softirqs ]; then 
	logHeader $main_folder/$LogDir/$logfile "io : softirqs"
	cp /proc/softirqs  $main_folder/$LogDir/$io_dir/soft_irqs$extension 2>>$errorlog
	logFooter $main_folder/$LogDir/$logfile "-" $main_folder/$LogDir/$io_dir
fi

if [ -f /proc/interrupts ]; then 
	logHeader $main_folder/$LogDir/$logfile "io : IRQS"
	cp /proc/interrupts $main_folder/$LogDir/$io_dir/interrupts$extension 2>>$errorlog
	logFooter $main_folder/$LogDir/$logfile "-" $main_folder/$LogDir/$io_dir
fi

logFileStubbSection $main_folder/$LogDir/$logfile $main_folder/$LogDir/$io_dir/ "- IO section ends " $io_dir

#Memory section
echo "- Memory section begins " >> $main_folder/$LogDir/$logfile
if [ -f /proc/pagetypeinfo ]; then 
	logHeader $main_folder/$LogDir/$logfile "memory : pagetype"
	cp /proc/pagetypeinfo  $main_folder/$LogDir/$memory_dir/pagetypeinfo$extension 2>>$errorlog
	logFooter $main_folder/$LogDir/$logfile "-" $main_folder/$LogDir/$memory_dir
fi


if [ -x "$(command -v free)" ]; then 
	logHeader $main_folder/$LogDir/$logfile "memory : free,meminfo"
	free --human > $main_folder/$LogDir/$memory_dir/memory_usage$extension
	cp /proc/meminfo  $main_folder/$LogDir/$memory_dir/memory_assigned$extension 2>>$errorlog
	logFooter $main_folder/$LogDir/$logfile "free" $main_folder/$LogDir/$memory_dir
fi 

if [ -f /proc/iomem ]; then 
	logHeader $main_folder/$LogDir/$logfile "memory : iomem"
	cp /proc/iomem  $main_folder/$LogDir/$memory_dir/io_memory_address$extension 2>>$errorlog
	logFooter $main_folder/$LogDir/$logfile "-" $main_folder/$LogDir/$memory_dir
fi

if [ -f /proc/vmalloc ]; then 
	logHeader $main_folder/$LogDir/$logfile "-memory : vmalloc"
	cp /proc/vmalloc  $main_folder/$LogDir/$memory_dir/os-system-version$extension 2>>$errorlog
	logFooter $main_folder/$LogDir/$logfile "-" $main_folder/$LogDir/$memory_dir
fi

#AEP Memory section
if [ -x "$(command -v ipmctl)" ]; then
	logHeader $main_folder/$LogDir/$logfile "-memory : ipmctl"
	ipmctl show -dimm >> $main_folder/$LogDir/$memory_dir/dcpmm_info$extension 2>>$errorlog
	ipmctl show -firmware >> $main_folder/$LogDir/$memory_dir/dcpmm_info$extension 2>>$errorlog
	ipmctl show -topology >> $main_folder/$LogDir/$memory_dir/dcpmm_info$extension 2>>$errorlog
	ipmctl show -system -capabilities >> $main_folder/$LogDir/$memory_dir/dcpmm_info$extension 2>>$errorlog
	ipmctl show -memoryresources >> $main_folder/$LogDir/$memory_dir/dcpmm_info$extension 2>>$errorlog
#	ipmctl show -d LastShutdownStatus -dimm >> $main_folder/$LogDir/$memory_dir/dcpmm_info$extension 2>>$errorlog
	ipmctl show -Sensor >> $main_folder/$LogDir/$memory_dir/dcpmm_info$extension 2>>$errorlog
	ipmctl show -d HealthState,ManageabilityState,FWVersion -dimm >> $main_folder/$LogDir/$memory_dir/dcpmm_info$extension 2>>$errorlog
	ipmctl show -d bootstatus -dimm  >> $main_folder/$LogDir/$memory_dir/dcpmm_info$extension 2>>$errorlog
	ipmctl show -d modessupported -system -capabilities >> $main_folder/$LogDir/$memory_dir/dcpmm_info$extension 2>>$errorlog
	ipmctl show -event >> $main_folder/$LogDir/$memory_dir/dcpmm_info$extension 2>>$errorlog
	logFooter $main_folder/$LogDir/$logfile "-" $main_folder/$LogDir/$memory_dir
fi

logFileStubbSection $main_folder/$LogDir/$logfile $main_folder/$LogDir/$memory_dir/ "- Memory section ends " $memory_dir

#Modules section
echo "- Modules section begins" >> $main_folder/$LogDir/$logfile

if [ -x "$(command -v lsmod)" ]; then 
	logHeader $main_folder/$LogDir/$logfile "modules : lsmod"
	lsmod | column -t > $main_folder/$LogDir/$modules_dir/lsmod_modules$extension
	logFooter $main_folder/$LogDir/$logfile "lsmod" $main_folder/$LogDir/$modules_dir
fi

if [ -f /proc/modules ]; then 
	logHeader $main_folder/$LogDir/$logfile "modules : modules list"
	cat /proc/modules | column -t > $main_folder/$LogDir/$modules_dir/modules$extension
	logFooter $main_folder/$LogDir/$logfile "-" $main_folder/$LogDir/$modules_dir
fi

logFileStubbSection $main_folder/$LogDir/$logfile $main_folder/$LogDir/$modules_dir "- modules section ends " $modules_dir

#Power Mngt Section

echo "- PowerMngt section begins" >> $main_folder/$LogDir/$logfile
if [ -d /sys/devices/system/cpu ]; then 
	logHeader $main_folder/$LogDir/$logfile "-PM: PowerDriver state"
	echo "CPU idle current driver :" > $main_folder/$LogDir/$power_dir/pwr-cstates-driver$extension
	cat /sys/devices/system/cpu/cpuidle/current_driver >> $main_folder/$LogDir/$power_dir/pwr-cstates-driver$extension
	echo "CPU Scaling driver :" >> $main_folder/$LogDir/$power_dir/pwr-cstates-driver$extension
	cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_driver >> $main_folder/$LogDir/$power_dir/pwr-cstates-driver$extension
	logFooter $main_folder/$LogDir/$logfile "-" $main_folder/$LogDir/$power_dir
fi

if [ -f /sys/power/state ]; then
	logHeader $main_folder/$LogDir/$logfile "-PM: Sleep/Suspend stats"
	echo "System states reported for suspend/S3"
	cat /sys/power/state > $main_folder/$LogDir/$power_dir/pwr-state-found$extension
	echo "System sleep state found :"
	cat /sys/power/mem_sleep > $main_folder/$LogDir/$power_dir/pwr-s3-state-found$extension
	logFooter $main_folder/$LogDir/$logfile "-" $main_folder/$LogDir/$power_dir
fi 

logFileStubbSection $main_folder/$LogDir/$logfile $main_folder/$LogDir/$power_dir/ "- PowerMngt section ends" $power_dir

#Network section
echo "- Network section begins" >> $main_folder/$LogDir/$logfile
if [ -f /proc/net/dev ]; then 
	logHeader $main_folder/$LogDir/$logfile "network : statistics"
	cat /proc/net/dev | column -t > $main_folder/$LogDir/$net_dir/network_devices_stats$extension
	logFooter $main_folder/$LogDir/$logfile "-" $main_folder/$LogDir/$net_dir
fi

if [ -x "$(command -v ifconfig)" ]; then 
	logHeader $main_folder/$LogDir/$logfile "network : ifconfig "
	ifconfig  > $main_folder/$LogDir/$net_dir/ifconfig$extension
	logFooter $main_folder/$LogDir/$logfile "-" $main_folder/$LogDir/$net_dir
fi 

if [ -x "$(command -v ip)" ]; then 
	logHeader $main_folder/$LogDir/$logfile "network : IP"
	ip  addr > $main_folder/$LogDir/$net_dir/network_ip_generic$extension
	logFooter $main_folder/$LogDir/$logfile "-" $main_folder/$LogDir/$net_dir
fi 

if [ -f /proc/hosts ]; then 
	logHeader $main_folder/$LogDir/$logfile "network : Hosts"
	cp /etc/hosts $main_folder/$LogDir/$net_dir/network_hosts
	logFooter $main_folder/$LogDir/$logfile "-" $main_folder/$LogDir/$net_dir
fi

if [ -x "$(command -v route)" ]; then 
	logHeader $main_folder/$LogDir/$logfile "network : routes"
	route > $main_folder/$LogDir/$net_dir/route.txt
	logFooter $main_folder/$LogDir/$logfile "-" $main_folder/$LogDir/$net_dir
fi

logFileStubbSection $main_folder/$LogDir/$logfile $main_folder/$LogDir/$net_dir/ "- Network section ends" $net_dir

#OS Enviroment section
echo "- OS Enviroment logs" >> $main_folder/$LogDir/$logfile

if [ -f /proc/swaps ]; then 
	logHeader $main_folder/$LogDir/$logfile "system : swap info"
	cp /proc/swaps $main_folder/$LogDir/$os_dir/swap_details$extension 2>>$errorlog
	logFooter $main_folder/$LogDir/$logfile "-" $main_folder/$LogDir/$os_dir
fi

if [ -f /proc/zoneinfo ]; then 
	logHeader $main_folder/$LogDir/$logfile "system : VM struct zone"
	cp /proc/zoneinfo $main_folder/$LogDir/$os_dir/vm_zoneinfo$extension 2>>$errorlog
	logFooter $main_folder/$LogDir/$logfile "-" $main_folder/$LogDir/$os_dir
fi

if [ -f /proc/version ]; then 
	logHeader $main_folder/$LogDir/$logfile "system : os version"
	cp /proc/version  $main_folder/$LogDir/$os_dir/linux_version$extension 2>>$errorlog
	logFooter $main_folder/$LogDir/$logfile "-" $main_folder/$LogDir/$os_dir
fi

if [ -f /var/log/messages ]; then 
	logHeader $main_folder/$LogDir/$logfile "system : messages"
	cp /var/log/messages $main_folder/$LogDir/$os_dir/messages$extension
	logFooter $main_folder/$LogDir/$logfile "-" $main_folder/$LogDir/$os_dir
fi

if [ -x "$(command -v dmesg)" ]; then 
	logHeader $main_folder/$LogDir/$logfile "system : dmesg"
	dmesg --level=warn > $main_folder/$LogDir/$os_dir/dmesg-warnings$extension
	dmesg --level=err > $main_folder/$LogDir/$os_dir/dmesg-errors$extension
	dmesg --level=crit > $main_folder/$LogDir/$os_dir/dmesg-critical$extension
	dmesg --level=debug > $main_folder/$LogDir/$os_dir/dmesg-debug$extension
	dmesg > $main_folder/$LogDir/$os_dir/dmesg$extension
	dmesg --human > $main_folder/$LogDir/$os_dir/dmesg_friendly$extension
	cp /var/run/dmesg.boot $main_folder/$LogDir/$os_dir/ 2>> $errorlog
	logFooter $main_folder/$LogDir/$logfile "-" $main_folder/$LogDir/$os_dir
fi

if [ -f /proc/cmdline ]; then 
	logHeader $main_folder/$LogDir/$logfile "system : OS Boot commandline"
	cp /proc/cmdline  $main_folder/$LogDir/$os_dir/linux_os_boot_line$extension 2>>$errorlog
	logFooter $main_folder/$LogDir/$logfile "-" $main_folder/$LogDir/$os_dir
fi

if [ -f /proc/crypto ]; then 
	logHeader $main_folder/$LogDir/$logfile "system  : OS Cryptography"
	cp /proc/crypto  $main_folder/$LogDir/$os_dir/linux_os_crypto$extension >>$errorlog
	logFooter $main_folder/$LogDir/$logfile "-" $main_folder/$LogDir/$os_dir
fi

if [ -x "$(command -v systemctl)" ]; then 
	logHeader $main_folder/$LogDir/$logfile "system : Systemd active units"
	systemctl list-unit-files > $main_folder/$LogDir/$os_dir/system_units$extension
	logFooter $main_folder/$LogDir/$logfile "-" $main_folder/$LogDir/$os_dir
fi

if [ -d "/etc/modprobe.d" ]; then 
	logHeader $main_folder/$LogDir/$logfile "system : modprob cfg"
	cp -R /etc/modprobe.d* $main_folder/$LogDir/$os_dir/etc/ 2>> $errorlog
	logFooter $main_folder/$LogDir/$logfile "-" $main_folder/$LogDir/$os_dir
fi

logHeader $main_folder/$LogDir/$logfile "system : drivers"
if [ -f $main_folder/$LogDir/$os_dir/drivers.txt ]; then 
	rm $main_folder/$LogDir/$os_dir/drivers.txt; 
fi
lsmod | sed 's/ .*//g' | sort | sed '/Module/d' >> $main_folder/$LogDir/$os_dir/module.txt
cat $main_folder/$LogDir/$os_dir/module.txt | while read line
do
	modinfo $line | grep -w "version:" >> $main_folder/$LogDir/$os_dir/version.txt
	VERSION=$main_folder/$LogDir/$os_dir/version.txt
	if [[ -s $VERSION ]]; then
		modinfo $line >> $main_folder/$LogDir/$os_dir/all_driver_info.txt
		modinfo $line | grep -e "description:"  >> $main_folder/$LogDir/$os_dir/drivers.txt
		modinfo $line | grep -w "filename:   " | sed 's/\/.*\///g' >> $main_folder/$LogDir/$os_dir/drivers.txt
		modinfo $line | grep -w "version:    "  >> $main_folder/$LogDir/$os_dir/drivers.txt
		modinfo $line | grep -w "name   :    "  >> $main_folder/$LogDir/$os_dir/drivers.txt
		modinfo $line | grep -w "depends:    "  >> $main_folder/$LogDir/$os_dir/drivers.txt
		modinfo $line | grep -w "vermagic :  "  >> $main_folder/$LogDir/$os_dir/drivers.txt
		modinfo $line | grep -w "intree   :  "  >> $main_folder/$LogDir/$os_dir/drivers.txt
		echo >> $main_folder/$LogDir/$os_dir/drivers.txt
	else
		continue
	fi
done
logFooter $main_folder/$LogDir/$logfile "-" $main_folder/$LogDir/$os_dir


logHeader $main_folder/$LogDir/$logfile "system : OS Packages info"
if [ -x "$(command -v yum)" ]; then 
	yum list all -y > $main_folder/$LogDir/$os_dir/yum_list_all_pkgs$extension 2>> $errorlog
	yum list installed -y > $main_folder/$LogDir/$os_dir/yum_list_only_installed_pkgs$extension 2>> $errorlog
	rpm -qa | sort > $main_folder/$LogDir/$os_dir/installed_rpms.txt 2>> $errorlog
fi 

if [ -x "$(command -v zypper)" ]; then 
	zypper pa > $main_folder/$LogDir/$os_dir/zypper_pkgs_avail$extension 2>> $errorlog
	rpm -qa | sort > $main_folder/$LogDir/$os_dir/installed_rpms.txt 2>> $errorlog
	rpm -qa --last | column -t | sort >> $main_folder/$LogDir/$os_dir/installed_rpms_history$extension 2>> $errorlog
fi

if [ -x "$(command -v apt-get)" ]; then 
	echo "0"
fi
logFooter $main_folder/$LogDir/$logfile "-" $main_folder/$LogDir/$os_dir

if [ -x "$(command -v /bin/bash)" ]; then 
	logHeader $main_folder/$LogDir/$logfile "system : command history"
	cp $HISTFILE $main_folder/$LogDir/$os_dir/history$extension 2>> $errorlog
	logFooter $main_folder/$LogDir/$logfile "-" $main_folder/$LogDir/$os_dir
fi

if [ -x "$(command -v ps)" ]; then
	logHeader $main_folder/$LogDir/$logfile "systemm : process tree"
	ps aux --forest >  $main_folder/$LogDir/$os_dir/ps_tree$extension 2>> $errorlog
	logFooter $main_folder/$LogDir/$logfile "-" $main_folder/$LogDir/$os_dir
fi

if [ -f /proc/stat ]; then 
	logHeader $main_folder/$LogDir/$logfile "-system  : stats"
	cp /proc/stat $main_folder/$LogDir/$os_dir/sys_stats$extensionc 2>>$errorlog
	logFooter $main_folder/$LogDir/$logfile "-" $main_folder/$LogDir/$os_dir
fi


if [ -f /proc/fb ]; then 
	logHeader $main_folder/$LogDir/$logfile "Frame buffer"
	cp /proc/fb  $main_folder/$LogDir/$os_dir/fb$extension 2>> $errorlog
	logFooter $main_folder/$LogDir/$logfile "-" $main_folder/$LogDir/$os_dir
fi
logFileStubbSection $main_folder/$LogDir/$logfile $main_folder/$LogDir/$os_dir/ "- OS Enviroment logs ends" $os_dir

logHeader $main_folder/$LogDir/$logfile "Misc : other logs"

if [ -x "$(command -v selview)" ]; then 
	logHeader $main_folder/$LogDir/$logfile "Selview"
	selview /save $main_folder/$LogDir/sut_$(date +%Y_%m_%d_%H_%M_%S).sel  1>>$errorlog
	selview /save /hex $main_folder/$LogDir/sut_$(date +%Y_%m_%d_%H_%M_%S)_hex.sel 1>>$errorlog
	logFooter $main_folder/$LogDir/$logfile "-" $main_folder/$LogDir/
fi

logHTMLFooter
# end 
echo "Script is done, you may want to check the logs on ${LogDir} "
echo "End time : " >> $main_folder/$LogDir/$logfile
date  >> $main_folder/$LogDir/$logfile
exit
