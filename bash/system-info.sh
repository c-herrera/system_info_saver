#!/bin/bash
# File          : system-info.sh
# Purpose       : Gather as much system info as possible
# Description   : Script will try to get as much system data as posible and save
#                 it a single location where user can pick and seek for whatever
#                 is required
# Version       : 0.0.9
# Date          : 2018-11-18-21:18
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
currenthost=$(cat /etc/hostname)
LogDir=sut_info_$(date +%Y_%m_%d_%H_%M_%S)
logfile=scriptlog.txt
version="0.0.9"
errorlog=$LogDir/errors.txt
htmllog=$LogDir/scriptlog.html

#script folders
hw_dir=hw_logs
os_dir=os_logs
net_dir=net_logs
power_dir=power_logs
storage_dir=storage_logs
io_dir=io_logs
memory_dir=memory_logs
modules_dir=modules_logs


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
	echo "</pre> <table widht=100%>" >> $htmllog
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
	mkdir --parents $LogDir/$hw_dir
	mkdir --parents $LogDir/$os_dir
	mkdir --parents $LogDir/$os_dir/etc/
	mkdir --parents $LogDir/$net_dir
	mkdir --parents $LogDir/$power_dir
	mkdir --parents $LogDir/$storage_dir
	mkdir --parents $LogDir/$memory_dir
	mkdir --parents $LogDir/$modules_dir
	mkdir --parents $LogDir/$io_dir
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
if  [ -d "$LogDir" ]
then
	echo "$LogDir directory exists, will continue"
	touch $LogDir/$logfile
	systembanner >> $LogDir/$logfile
	echo "" >> $LogDir/$logfile
	date >> $LogDir/$logfile
	# Create folder for logs
	folderSetup
else
	echo "$LogDir directory not found, creating one"
	mkdir $LogDir
	touch $LogDir/$logfile
	systembanner >> $LogDir/$logfile
	echo "" >> $LogDir/$logfile
	# Create folder for logs
	date >> $LogDir/$logfile
	folderSetup
fi

# Checking this does not hurt
if [ -d  "/bin" ]
then 
	echo "main directory BIN is present continue ..." >> $LogDir/$logfile
else
	echo "BIN directory is not present at // bailing out..." >> $LogDir/$errorlog
	exit 1
fi

# Get rid of all the term clutter
clear

# A nice introduction ....
systembanner

# Annnnd proceed with the script ...

echo "- Starting the recolletion " >> $LogDir/$logfile
echo "- Process started at $(date +%Y:%m:%d:%H:%M:%S) " >> $LogDir/$logfile

logHTMLHeader

# Hardware logs section
echo "- Hardware section starts :" >> $LogDir/$logfile

if [ -x "$(command -v lshw)" ]; then 
	logHeader $LogDir/$logfile "-HW : lshw"
	lshw -html > $LogDir/$hw_dir/lshw-system-info.html
	lshw -short >$LogDir/$hw_dir/lshw-system-info-brief.log
	logFooter $LogDir/$logfile "-" $LogDir/$hw_dir/
fi

if [ -x "$(command -v hwinfo)" ]; then 
	logHeader $LogDir/$logfile "-HW : hwinfo"
	hwinfo --all --log=$LogDir/$hw_dir/hwinfo.log
	logFooter $LogDir/$logfile "-" $LogDir/$hw_dir/
fi


if [ -x "$(command -v dmidecode)" ]; then 
	logHeader $LogDir/$logfile "-HW : dmidecode"
	dmidecode > $LogDir/$hw_dir/dmidecode-system-dmi-full-hw.log
	logFooter $LogDir/$logfile "-" $LogDir/$hw_dir/
fi


if [ -x "$(command -v lspci)" ]; then 
	logHeader $LogDir/$logfile "-HW : lspci"
	lspci -t -vmm > $LogDir/$hw_dir/lspci-pci-devices-topology-verbose.log
	lspci -vvvxxx > $LogDir/$hw_dir/lspci-pci-devices-extra-verbose.log
	logFooter $LogDir/$logfile "-" $LogDir/$hw_dir/
fi

if [ -x "$(command -v lscpu)" ]; then 
	logHeader $LogDir/$logfile "-HW : lscpu"
	lscpu > $LogDir/$hw_dir/lscpu-cpu-basic.log
	lscpu --extended --all | column -t > $LogDir/$hw_dir/lscpu-extended.log
	logFooter $LogDir/$logfile "-" $LogDir/$hw_dir/
fi 

if [ -f /proc/cpuinfo  ]; then 
	logHeader $LogDir/$logfile "-HW : lspcpu"
	cp /proc/cpuinfo $LogDir/$hw_dir/cpuinfo.log 2>> $errorlog
	logFooter $LogDir/$logfile "-" $LogDir/$hw_dir/
fi

if [ -f /proc/schedstat ]; then 
	logHeader $LogDir/$logfile "-HW : cpu schedule"
	cp /proc/schedstat $LogDir/$hw_dir/cpu_schedule.log 2>>$errorlog
	logFooter $LogDir/$logfile "-" $LogDir/$hw_dir/
fi


if [ -f /var/log/xorg.0.log ]; then 
	logHeader $LogDir/$logfile "HW : x-server"
	cp /var/log/xorg.0.log $LogDir/$hw_dir/ 2>> $errorlog
	logFooter $LogDir/$logfile "-" $LogDir/$hw_dir/
fi


if [ -f /proc/devices ]; then 
	logHeader $LogDir/$logfile "-HW : devices"
	cp /proc/devices $LogDir/$hw_dir/devices.log 2>> $errorlog
	logFooter $LogDir/$logfile "-" $LogDir/$hw_dir/
fi

logFileStubbSection $LogDir/$logfile $LogDir/$hw_dir/ "- HW.Section.End " $hw_dir

# Storage logs section
echo "- Storage section begins " >> $LogDir/$logfile
if [ -f /proc/cpuinfo  ]; then 
	logHeader $LogDir/$logfile "-STRG : lsblk"
	lsblk --all --ascii --perms --fs > $LogDir/$storage_dir/lsblk.log
	logFooter $LogDir/$logfile "-" $LogDir/$storage_dir/
fi 

if [ -x "$(command -v lsscsi)" ]; then 
	logHeader $LogDir/$logfile "-STRG : lsscsi"
	lsscsi --size --verbose | column -t > $LogDir/$storage_dir/lsssci-verbose.log
	logFooter $LogDir/$logfile "lsscsi" $LogDir/$storage_dir/
fi

if [ -x "$(command -v fdisk)" ]; then 
	logHeader $LogDir/$logfile "-STRG : fdisk"
	fdisk -l > $LogDir/$storage_dir/fdisk.log
	logFooter $LogDir/$logfile "-" $LogDir/$storage_dir/
fi

if [ -x "$(command -v df)" ]; then 
	logHeader $LogDir/$logfile "-STRG : df"
	df -h > $LogDir/$storage_dir/df-usage.log
	logFooter $LogDir/$logfile "-" $LogDir/$storage_dir/
fi

if [ -f /proc/partitions  ];then 
	logHeader $LogDir/$logfile "-STRG : partition file"
	cp /proc/partitions $LogDir/$storage_dir/partitions.log 2>> $errorlog
	logFooter $LogDir/$logfile "-" $LogDir/$storage_dir/
fi

if [ -x "$(command -v mount)" ]; then 
	logHeader $LogDir/$logfile "STRG : mount"
	mount | column -t > $LogDir/$storage_dir/mounted_devices.log
	logFooter $LogDir/$logfile "-" $LogDir/$storage_dir/
fi

if [ -f /proc/scsi  ]; then 
	logHeader $LogDir/$logfile "STRG : scsi"
	cat /proc/scsi/scsi >> $LogDir/$storage_dir/scsi_devices.log
	logFooter $LogDir/$logfile "-" $LogDir/$storage_dir/
fi

if [ -f /proc/scsi/mounts ]; then 
	logHeader $LogDir/$logfile "STRG : scsi-mounts"
	cp /proc/scsi/mounts  $LogDir/$storage_dir/scsi-mounts.log 2>>$errorlog
	logFooter $LogDir/$logfile "-" $LogDir/$storage_dir/
fi

if [ -f /proc/diskstats ]; then 
	logHeader $LogDir/$logfile "STRG : diskstats"
	cat /proc/diskstats | column -t >> $LogDir/$storage_dir/diskstats.log
	logFooter $LogDir/$logfile "-" $LogDir/$storage_dir/
fi

if [ -f /proc/filesystems ]; then 
	logHeader $LogDir/$logfile "STRG : filesystems"
	cat /proc/filesystems >> $LogDir/$storage_dir/fs_systems.log
	logFooter $LogDir/$logfile "-" $LogDir/$storage_dir/
fi


if [ -x "$(command -v blockdev)" ]; then 
	logHeader $LogDir/$logfile "STRG : blockdev"
	blockdev --report  >> $LogDir/$storage_dir/blockdevices.log
	logFooter $LogDir/$logfile "-" $LogDir/$storage_dir/
fi

if [ -x "$(command -v swapon)" ]; then 
	logHeader $LogDir/$logfile "-STRG : swaps"
	swapon --all --summary --verbose  >> $LogDir/$storage_dir/blockdevices.log
	logFooter $LogDir/$logfile "-" $LogDir/$storage_dir/
fi


logFileStubbSection $LogDir/$logfile $LogDir/$storage_dir/ "- Storage section ends " $storage_dir

#IO section
echo "- IO section begins " >> $LogDir/$logfile

if [ -f /proc/ioports ]; then 
	logHeader $LogDir/$logfile "-IO : ioports"
	cp /proc/ioports  $LogDir/$io_dir/io_ports.log 2>>$errorlog
	logFooter $LogDir/$logfile "-" $LogDir/$io_dir
fi 

if [ -x "$(command -v lsusb)" ]; then 
	logHeader $LogDir/$logfile "-IO : lsusb"
	lsusb -t > $LogDir/$io_dir/lsusb_topology.log
	lsusb > $LogDir/$io_dir/lsusb_normal.log
	logFooter $LogDir/$logfile "-" $LogDir/$io_dir
fi

if [ -f /proc/softirqs ]; then 
	logHeader $LogDir/$logfile "-IO : softirqs"
	cp /proc/softirqs  $LogDir/$io_dir/soft_irqs.log 2>>$errorlog
	logFooter $LogDir/$logfile "-" $LogDir/$io_dir
fi

if [ -f /proc/interrupts ]; then 
	logHeader $LogDir/$logfile "-IO : irqs"
	cp /proc/interrupts  $LogDir/$io_dir/interrupts.log 2>>$errorlog
	logFooter $LogDir/$logfile "-" $LogDir/$io_dir
fi

logFileStubbSection $LogDir/$logfile $LogDir/$io_dir/ "- IO section ends " $io_dir

#Memory section
echo "- Memory section begins " >> $LogDir/$logfile
if [ -f /proc/pagetypeinfo ]; then 
	logHeader $LogDir/$logfile "-MEM : pagetype"
	cp /proc/pagetypeinfo  $LogDir/$memory_dir/pagetypeinfo.log 2>>$errorlog
	logFooter $LogDir/$logfile "-" $LogDir/$memory_dir
fi


if [ -x "$(command -v free)" ]; then 
	logHeader $LogDir/$logfile "-MEM : free,meminfo"
	free --human > $LogDir/$memory_dir/memory_usage.log
	cp /proc/meminfo  $LogDir/$memory_dir/memory_assigned.log 2>>$errorlog
	logFooter $LogDir/$logfile "free" $LogDir/$memory_dir
fi 

if [ -f /proc/iomem ]; then 
	logHeader $LogDir/$logfile "-MEM : iomem"
	cp /proc/iomem  $LogDir/$memory_dir/io_memory_address.log 2>>$errorlog
	logFooter $LogDir/$logfile "IO mem" $LogDir/$memory_dir
fi

if [ -f /proc/vmalloc ]; then 
	logHeader $LogDir/$logfile "-MEM : vmalloc"
	cp /proc/vmalloc  $LogDir/$memory_dir/os-system-version.log 2>>$errorlog
	logFooter $LogDir/$logfile "Allocation Memory" $LogDir/$memory_dir
fi

logFileStubbSection $LogDir/$logfile $LogDir/$memory_dir/ "- Memory section ends " $memory_dir

#Modules section
echo "- Modules section begins" >> $LogDir/$logfile

if [ -x "$(command -v lsmod)" ]; then 
	logHeader $LogDir/$logfile "lsmod"
	lsmod | column -t > $LogDir/$modules_dir/lsmod_modules.log
	logFooter $LogDir/$logfile "lsmod" $LogDir/$modules_dir
fi

if [ -f /proc/modules ]; then 
	logHeader $LogDir/$logfile "loaded modules"
	cat /proc/modules | column -t > $LogDir/$modules_dir/modules.log
	logFooter $LogDir/$logfile "loaded modules" $LogDir/$modules_dir
fi

logFileStubbSection $LogDir/$logfile $LogDir/$modules_dir "- Modules section ends " $modules_dir

#Power Mngt Section

echo "- PowerMngt section begins" >> $LogDir/$logfile
if [ -d /sys/devices/system/cpu ]; then 
	logHeader $LogDir/$logfile "PowerDriver state"
	echo "CPU idle current driver :" > $LogDir/$power_dir/pwr-cstates-driver.log
	cat /sys/devices/system/cpu/cpuidle/current_driver >> $LogDir/$power_dir/pwr-cstates-driver.log
	echo "CPU Scaling driver :" >> $LogDir/$power_dir/pwr-cstates-driver.log
	cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_driver >> $LogDir/$power_dir/pwr-cstates-driver.log
	logFooter $LogDir/$logfile "PowerDriver state" $LogDir/$power_dir
fi

logFileStubbSection $LogDir/$logfile $LogDir/$power_dir/ "- PowerMngt section ends" $power_dir

#Network section
echo "- Network section begins" >> $LogDir/$logfile
if [ -f /proc/net/dev ]; then 
	logHeader $LogDir/$logfile "Network devices statistics"
	cat /proc/net/dev | column -t > $LogDir/$net_dir/network_devices_stats.log
	logFooter $LogDir/$logfile "Network devices statistics" $LogDir/$net_dir
fi

if [ -x "$(command -v ifconfig)" ]; then 
	logHeader $LogDir/$logfile "ifconfig "
	ifconfig  > $LogDir/$net_dir/ifconfig.log
	logFooter $LogDir/$logfile "ifconfig" $LogDir/$net_dir
fi 

if [ -x "$(command -v ip)" ]; then 
	logHeader $LogDir/$logfile "IP address"
	ip  addr > $LogDir/$net_dir/network_ip_generic.log
	logFooter $LogDir/$logfile "IP address" $LogDir/$net_dir
fi 

if [ -f /proc/hosts ]; then 
	logHeader $LogDir/$logfile "Hosts conf"
	cp /etc/hosts $LogDir/$net_dir/network_hosts
	logFooter $LogDir/$logfile "Hosts conf" $LogDir/$net_dir
fi

if [ -x "$(command -v route)" ]; then 
	logHeader $LogDir/$logfile "routes"
	route > $LogDir/$net_dir/route.txt
	logFooter $LogDir/$logfile "routes" $LogDir/$net_dir
fi

logFileStubbSection $LogDir/$logfile $LogDir/$net_dir/ "- Network section ends" $net_dir

#OS Enviroment section
echo "- OS Enviroment logs" >> $LogDir/$logfile

if [ -f /proc/swaps ]; then 
	logHeader $LogDir/$logfile "Swap details"
	cat /proc/swaps >> $LogDir/$os_dir/swap_details.log
	logFooter $LogDir/$logfile "Swap details" $LogDir/$os_dir
fi

if [ -f /proc/zoneinfo ]; then 
	logHeader $LogDir/$logfile "VM struct zone"
	cat /proc/zoneinfo >> $LogDir/$os_dir/os_vm_zoneinfo.log
	logFooter $LogDir/$logfile "VM struct zone" $LogDir/$os_dir
fi

if [ -f /proc/version ]; then 
	logHeader $LogDir/$logfile "System version"
	cat /proc/version >> $LogDir/$os_dir/os-system-version.log
	logFooter $LogDir/$logfile "System version" $LogDir/$os_dir
fi

if [ -f /var/log/messages ]; then 
	logHeader $LogDir/$logfile "System messages"
	cp /var/log/messages $LogDir/$os_dir/messages.log
	logFooter $LogDir/$logfile "System messages" $LogDir/$os_dir
fi

if [ -x "$(command -v dmesg)" ]; then 
	logHeader $LogDir/$logfile "dmesg"
	dmesg --level=warn > $LogDir/$os_dir/dmesg-warnings.log
	dmesg --level=err > $LogDir/$os_dir/dmesg-errors.log
	dmesg --level=crit > $LogDir/$os_dir/dmesg-critical.log
	dmesg --level=debug > $LogDir/$os_dir/dmesg-debug.log
	dmesg > $LogDir/$os_dir/dmesg.log
	cp /var/run/dmesg.boot $LogDir/$os_dir/ 2>> $errorlog
	logFooter $LogDir/$logfile "dmesg" $LogDir/$os_dir
fi

if [ -f /proc/cmdline ]; then 
	logHeader $LogDir/$logfile "OS Boot commandline"
	cat /proc/cmdline > $LogDir/$os_dir/linux_os_boot_line.log
	logFooter $LogDir/$logfile "OS Boot commandline" $LogDir/$os_dir
fi

if [ -f /proc/crypto ]; then 
	logHeader $LogDir/$logfile "OS Cryptography"
	cat /proc/crypto > $LogDir/$os_dir/linux_os_crypto.log
	logFooter $LogDir/$logfile "OS Cryptography" $LogDir/$os_dir
fi

if [ -x "$(command -v systemctl)" ]; then 
	logHeader $LogDir/$logfile "Systemd active units"
	systemctl list-unit-files > $LogDir/$os_dir/system_units.log
	logFooter $LogDir/$logfile "Systemd active units" $LogDir/$os_dir
fi

if [ -d "/etc/modprobe.d" ]; then 
	logHeader $LogDir/$logfile "Modules comfig"
	cp -R /etc/modprobe.d* $LogDir/$os_dir/etc/ 2>> $errorlog
	logFooter $LogDir/$logfile "Modules config" $LogDir/$os_dir
fi

logHeader $LogDir/$logfile "Driver modules info"
if [ -f $LogDir/$os_dir/drivers.txt ]; then 
	rm $LogDir/$os_dir/drivers.txt; 
fi
lsmod | sed 's/ .*//g' | sort | sed '/Module/d' >> $LogDir/$os_dir/module.txt
cat $LogDir/$os_dir/module.txt | while read line
do
	modinfo $line | grep -w "version:" >> $LogDir/$os_dir/version.txt
	VERSION=$LogDir/$os_dir/version.txt
	if [[ -s $VERSION ]]; then
		modinfo $line >> $LogDir/$os_dir/all_driver_info.txt
		modinfo $line | grep -e "description:"  >> $LogDir/$os_dir/drivers.txt
		modinfo $line | grep -w "filename:   " | sed 's/\/.*\///g' >> $LogDir/$os_dir/drivers.txt
		modinfo $line | grep -w "version:    "  >> $LogDir/$os_dir/drivers.txt
		modinfo $line | grep -w "name   :    "  >> $LogDir/$os_dir/drivers.txt
		modinfo $line | grep -w "depends:    "  >> $LogDir/$os_dir/drivers.txt
		modinfo $line | grep -w "vermagic :  "  >> $LogDir/$os_dir/drivers.txt
		modinfo $line | grep -w "intree   :  "  >> $LogDir/$os_dir/drivers.txt
		echo >> $LogDir/$os_dir/drivers.txt
	else
		continue
	fi
done
logFooter $LogDir/$logfile "Driver modules info" $LogDir/$os_dir


logHeader $LogDir/$logfile "OS Packages info"
if [ -x "$(command -v yum)" ]; then 
	yum list all -y > $LogDir/$os_dir/yum_list_all_pkgs.log 2>> $errorlog
	yum list installed -y > $LogDir/$os_dir/yum_list_only_installed_pkgs.log 2>> $errorlog
	rpm -qa | sort > $LogDir/$os_dir/installed_rpms.txt 2>> $errorlog
fi 

if [ -x "$(command -v zypper)" ]; then 
	zypper pa > $LogDir/$os_dir/zypper_pkgs_avail.log 2>> $errorlog
	rpm -qa | sort > $LogDir/$os_dir/installed_rpms.txt 2>> $errorlog
	rpm -qa --last | column -t | sort >> $LogDir/$os_dir/installed_rpms_history.log 2>> $errorlog
fi

if [ -x "$(command -v apt-get)" ]; then 
	echo "0"
fi
logFooter $LogDir/$logfile "OS Packages info" $LogDir/$os_dir

if [ -x "$(command -v /bin/bash)" ]; then 
	logHeader $LogDir/$logfile "OS command history"
	history > $LogDir/$os_dir/history.log 2>> $errorlog
	logFooter $LogDir/$logfile "OS command history" $LogDir/$os_dir
fi

if [ -x "$(command -v ps)" ]; then
	logHeader $LogDir/$logfile "Current process tree"
	ps aux --forest >  $LogDir/$os_dir/ps_tree.log 2>> $errorlog
	logFooter $LogDir/$logfile "Current process tree" $LogDir/$os_dir
fi

if [ -f /proc/stat ]; then 
	logHeader $LogDir/$logfile "System stats"
	cat /proc/stat > $LogDir/$os_dir/sys_stats.log
	logFooter $LogDir/$logfile "System stats" $LogDir/$os_dir
fi


if [ -f /proc/fb ]; then 
	logHeader $LogDir/$logfile "Frame buffer"
	cp /proc/fb  $LogDir/$os_dir/fb.log 2>> $errorlog
	logFooter $LogDir/$logfile "Frame Buffer" $LogDir/$os_dir
fi


logFileStubbSection $LogDir/$logfile $LogDir/$os_dir/ "- OS Enviroment logs ends" $os_dir

logHTMLFooter
# end 
echo "Script is done, you may want to check the logs on ${LogDir} "
echo "End time : " >> $LogDir/$logfile
date  >> $LogDir/$logfile
exit
