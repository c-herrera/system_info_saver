#!/bin/bash
# File          : system-info.sh
# Purpose       : Gather as much system info as possible
# Description   : Script will try to get as much system data as posible and save
#                 it a single location where user can pick and seek for whatever
#                 is required
# Version       : 0.1.32
# Date          : 2019-10-06-23:39
# Created by    : Carlos Herrera.
# Notes         : To run type sh system-info.sh in a system terminal with root access.
#                 If modified, please contact the autor to add and check the changes
# Scope         : Generic linux info gathering script, tested on RHEL 7.5, 8.0 beta, SUSE15
#               : Do not remove this header, thanks!

# Fun times on errors!
set +x
# set otherwise on for fun !!!

# Setting some vars to use :
arch=-1
kernel=-1
distroname=1
distroshortname=1
distrovar=1
distrotype=1
extension=.txt
currenthost=$(cat /etc/hostname)
LogDir=sut_info_$(date +%Y_%m_%d_%H_%M_%S)
logfile=summary.txt
version="0.1.32"
mainfolder=./evidence
platformfolder=sys_info
target=$mainfolder/$platformfolder
errorlog=$target/$LogDir/errors.txt
htmllog=$target/$LogDir/log_summary.html

#script folders
hw_dir=hw
os_dir=os
net_dir=net
power_dir=power
storage_dir=storage
io_dir=io
memory_dir=memory
modules_dir=modules
ps_dir=processes

# --------------------- snippets and whatnots -----------------------------------
#Pause function
function pause(){
	echo "Press the Enter key to continue..."
	read -p "$*"
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
	echo "<tr><td> $2  </td></tr>" >> $htmllog
}

# $1 text log
function logFooter() {		
	#to log
	#echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $2 ] " >> $1  
	echo "<tr><td> $2  </td> <td> saved in folder $3 </td> </tr>" >> $htmllog
}

function runCmd_and_Log_it ()
{
	progrm=$1
	arguments=$2
	logfilepath=$3
	errorlog=$4		
	if [ -x "$(command -v $progrm)" ]; then 		
		# Line for log
		echo " - $progrm will run with the next argument(s) : $arguments; on $(date)" >> $logfilepath		
		# line for screen
		echo " - $progrm found ! ...."
		$progrm $arguments >> $logfilepath
		echo " - Saved output at : $logfilepath"
	else
		echo "$progrm is not installed/missing path" >> $errorlog
	fi
	
}

function findLog_and_Save_it ()
{
	syslogfilepath=$1	
	logfilepath=$2
	errorlog=$3		
	if [ -f $syslogfilepath ]; then 
		# line for log
		echo " - $syslogfilepath is found, saved on $(date)" >> $logfilepath
		# line for screen
		echo " - $syslogfilepath exists! ...."
		cat $syslogfilepath >> $logfilepath
		echo " - Saved output at : $logfilepath"
	else
		echo "$syslogfilepath is not found" >> $errorlog
	fi	
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
	echo "System Report "
	echo "Running  on : $(cat /etc/hostname) ($(hostname -i | awk '{print $1}')) "
	echo "Generated at $(date)"
	echo "************************************************************"
	echo " Uptime: $(uptime)"
	echo " Kernel Version: $(uname -r)"
	echo " System load : $(cat /proc/loadavg | column -t)"
	echo " Disk status: $(df -h / | awk 'FNR == 2 {print $5 " used (" $4 " free)"}')"
	echo " Memory status: $(free -h | awk 'FNR == 2 {print $3 " used (" $4 " free)"}')"
	echo " Number of cpu(s): $(nproc) "
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
		*)
		distrovar=$distroshortname
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

function script_setup () {
	echo "Creating directory for logs"
	# Make our new logging directory
	if  [ -d "$LogDir" ]
	then
		echo "$LogDir directory exists, will continue"
		touch $target/$LogDir/$logfile
		systembanner >> $target/$LogDir/$logfile
		echo "" >> $target/$LogDir/$logfile
		date >> $target/$LogDir/$logfile
		# Create folder for logs
		folderSetup
	else
		echo "$LogDir directory not found, creating one"
		if [ -d "$mainfolder" ] 
		then 
			echo "Main folder $mainfolder exist already, moving on..."
		else
			echo "Main folder $mainfolder not found, creating one..."
			mkdir $mainfolder
		fi

		if [ -d "$mainfolder/$platformfolder" ]
		then
			echo "Platform folder $platformfolder already exist, moving on ..."
		else
			echo "Platform folder $platformfolder not found, creating one..."
			mkdir --parents $mainfolder/$platformfolder
		fi
		mkdir --parents $target/$LogDir
		touch $target/$LogDir/$logfile
		systembanner >> $target/$LogDir/$logfile
		echo "" >> $target/$LogDir/$logfile
		# Create folder for logs
		date >> $target/$LogDir/$logfile
		folderSetup
	fi
}


#Main folders setup
function folderSetup(){
	mkdir --parents $target/$LogDir/$hw_dir
	mkdir --parents $target/$LogDir/$os_dir
	mkdir --parents $target/$LogDir/$os_dir/etc/
	mkdir --parents $target/$LogDir/$net_dir
	mkdir --parents $target/$LogDir/$power_dir
	mkdir --parents $target/$LogDir/$storage_dir
	mkdir --parents $target/$LogDir/$memory_dir
	mkdir --parents $target/$LogDir/$modules_dir
	mkdir --parents $target/$LogDir/$io_dir
	mkdir --parents $target/$LogDir/$ps_dir
}

function get_sys_info(){
	#OS Enviroment section
	echo " OS info"
	
	findLog_and_Save_it '/proc/swaps' $target/$LogDir/$os_dir/swaps_detailed$extension $errorlog
	findLog_and_Save_it '/proc/zoneinfo' $target/$LogDir/$os_dir/vm_zoneinfo$extension $errorlog
	findLog_and_Save_it '/proc/version' $target/$LogDir/$os_dir/linux_version$extension $errorlog
	findLog_and_Save_it '/var/log/messages' $target/$LogDir/$os_dir/messages$extension $errorlog

	runCmd_and_Log_it 'dmesg' '--decode --human --level=warn' $target/$LogDir/$os_dir/dmesg-level_warnings$extension $errorlog
	runCmd_and_Log_it 'dmesg' '--decode --human --level=err' $target/$LogDir/$os_dir/dmesg-level_errors$extension $errorlog
	runCmd_and_Log_it 'dmesg' '--decode --human --level=crit' $target/$LogDir/$os_dir/dmesg-level_crital$extension $errorlog
	runCmd_and_Log_it 'dmesg' '--decode --human --level=debug' $target/$LogDir/$os_dir/dmesg-level_debug$extension $errorlog
	runCmd_and_Log_it 'dmesg' '--decode --human' $target/$LogDir/$os_dir/dmesg$extension $errorlog
	findLog_and_Save_it 'var/run/dmesg.boot' $target/$LogDir/$os_dir/dmesg-boot$extension $errorlog
	
	findLog_and_Save_it '/proc/cmdline' $target/$LogDir/$os_dir/linux_os_boot_line$extension $errorlog
	findLog_and_Save_it '/proc/crypto' $target/$LogDir/$os_dir/linux_os_crypto$extension $errorlog	
	runCmd_and_Log_it 'systemctl' 'list-unit-files' $target/$LogDir/$os_dir/system_units$extension $errorlog
	
	#if [ -d "/etc/modprobe.d" ]; then 
	#	logHeader $target/$LogDir/$logfile "system : modprob cfg"
	#	cp -R /etc/modprobe.d* $target/$LogDir/$os_dir/etc/ 2>> $errorlog
	#	logFooter $target/$LogDir/$logfile "-" $target/$LogDir/$os_dir
	#fi
	
	runCmd_and_Log_it 'lsmod' '| column --table' $target/$LogDir/$os_dir/lsmod_modules$extension $errorlog
	
	findLog_and_Save_it '/proc/modules' $target/$LogDir/$os_dir/modules_file$extension $errorlog
	
	if [ -f $target/$LogDir/$os_dir/drivers.txt ]; then 
		rm $target/$LogDir/$os_dir/drivers.txt; 
	fi
	lsmod | sed 's/ .*//g' | sort | sed '/Module/d' >> $target/$LogDir/$os_dir/module.txt
	cat $target/$LogDir/$os_dir/module.txt | while read line
	do
		modinfo $line | grep -w "version:" >> $target/$LogDir/$os_dir/version.txt
		VERSION=$target/$LogDir/$os_dir/version.txt
		if [[ -s $VERSION ]]; then
			modinfo $line >> $target/$LogDir/$os_dir/all_driver_info.txt
			modinfo $line | grep -e "description:"  >> $target/$LogDir/$os_dir/drivers.txt
			modinfo $line | grep -w "filename:   " | sed 's/\/.*\///g' >> $target/$LogDir/$os_dir/drivers.txt
			modinfo $line | grep -w "version:    "  >> $target/$LogDir/$os_dir/drivers.txt
			modinfo $line | grep -w "name   :    "  >> $target/$LogDir/$os_dir/drivers.txt
			modinfo $line | grep -w "depends:    "  >> $target/$LogDir/$os_dir/drivers.txt
			modinfo $line | grep -w "vermagic :  "  >> $target/$LogDir/$os_dir/drivers.txt
			modinfo $line | grep -w "intree   :  "  >> $target/$LogDir/$os_dir/drivers.txt
			echo >> $target/$LogDir/$os_dir/drivers.txt
		else
			continue
		fi
	done
	

	runCmd_and_Log_it 'yum' 'list all -y' $target/$LogDir/$os_dir/yum_list_all_pkgs$extension $errorlog
	runCmd_and_Log_it 'yum' 'list installed -y' $target/$LogDir/$os_dir/yum_list_only_installed_pkgs$extension $errorlog
	
	runCmd_and_Log_it 'zypper' 'pa' $target/$LogDir/$os_dir/zypper_pkgs_avail$extension $errorlog
	
	runCmd_and_Log_it 'rpm' '-qa | last | columnt -t | sort' $target/$LogDir/$os_dir/installed_rpms_history$extension $errorlog
	runCmd_and_Log_it 'rpm' '-qa | sort' $target/$LogDir/$os_dir/installed_rpms_sorted.txt $errorlog
	
	runCmd_and_Log_it 'history' ' ' $target/$LogDir/$os_dir/history_cmd$extension  $errorlog
	findLog_and_Save_it '/proc/stat' $target/$LogDir/$os_dir/sys_stats$extension $errorlog
	findLog_and_Save_it '/proc/fb' $target/$LogDir/$os_dir/fb$extension $errorlog
	findLog_and_Save_it '/proc/fb' $target/$LogDir/$os_dir/fb$extension $errorlog
	
	runCmd_and_Log_it 'env' ' ' $target/$LogDir/$os_dir/enviroment$extension  $errorlog
}


function get_power_info() {
	#Power Mngt Section
	echo "- PowerMngt section begins" >> $target/$LogDir/$logfile
	if [ -d /sys/devices/system/cpu ]; then 
		logHeader $target/$LogDir/$logfile "-PM: PowerDriver state"
		echo "CPU idle current driver :" > $target/$LogDir/$power_dir/pwr-cstates-driver$extension
		cat /sys/devices/system/cpu/cpuidle/current_driver >> $target/$LogDir/$power_dir/pwr-cstates-driver$extension 2>> $errorlog
		echo "CPU Scaling driver :" >> $target/$LogDir/$power_dir/pwr-cstates-driver$extension
		cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_driver >> $target/$LogDir/$power_dir/pwr-cstates-driver$extension 2>> $errorlog
		logFooter $target/$LogDir/$logfile "-" $target/$LogDir/$power_dir
	fi

	if [ -f /sys/power/state ]; then
		logHeader $target/$LogDir/$logfile "-PM: Sleep/Suspend stats"
		echo "System states reported for suspend/S3" >> $target/$LogDir/$power_dir/pwr-state-found$extension
		cp /sys/power/state  $target/$LogDir/$power_dir/pwr-state-found$extension 2>> $errorlog
		echo "System sleep state found :" >> $target/$LogDir/$power_dir/pwr-s3-state-found$extension
		cp /sys/power/mem_sleep  $target/$LogDir/$power_dir/pwr-s3-state-found$extension 2>> $errorlog
		logFooter $target/$LogDir/$logfile "-" $target/$LogDir/$power_dir
	fi 

	if [ -x "$(command -v cpupower)" ]; then 
		logHeader $target/$LogDir/$logfile "-PM: CPUPower info commands"
		cpupower frequency-info >> $target/$LogDir/$power_dir/cpupower-frequency_info$extension 2>> $errorlog
		cpupower idle-info >>  $target/$LogDir/$power_dir/cpupower-idle_info$extension 2>> $errorlog
		cpupower powercap-info >>  $target/$LogDir/$power_dir/cpupower-powercap$extension 2>> $errorlog
		cpupower monitor >>  $target/$LogDir/$power_dir/cpupower-monitor$extension 2>> $errorlog
		logFooter $target/$LogDir/$logfile "-" $target/$LogDir/$power_dir
	fi
	
	logFileStubbSection $target/$LogDir/$logfile $target/$LogDir/$power_dir/ "- PowerMngt section ends" $power_dir
}



function get_process_info() {
	echo "process specs"
	
	if [ -x "$(command -v ps)" ]; then
		logHeader $target/$LogDir/$logfile "systemm : process tree"
		ps aux --forest >  $target/$LogDir/$ps_dir/ps_forest$extension 2>> $errorlog
		logFooter $target/$LogDir/$logfile "-" $target/$LogDir/$ps_dir
	fi
	
	if [ -x "$(command -v ipcs)" ]; then
		logHeader $target/$LogDir/$logfile "systemm : process tree"
		ipcs --all --human >  $target/$LogDir/$os_dir/ipcs$extension 2>> $errorlog
		logFooter $target/$LogDir/$logfile "-" $target/$LogDir/$ps_dir		
	fi
	
	if [ -x "$(command -v pstree)" ]; then
		logHeader $target/$LogDir/$logfile "systemm : process tree"
		pstree --arguments --ascii >  $target/$LogDir/$os_dir/pstree$extension 2>> $errorlog
		logFooter $target/$LogDir/$logfile "-" $target/$LogDir/$ps_dir		
	fi

		if [ -f /proc/self/maps ]; then
		logHeader $target/$LogDir/$logfile "systemm : process tree"
		cat /proc/self/maps >  $target/$LogDir/$os_dir/maps_exe_libs$extension 2>> $errorlog
		logFooter $target/$LogDir/$logfile "-" $target/$LogDir/$ps_dir		
	fi
	
}


function get_memory_info() {	
	#Memory section
	echo "- Memory section begins " >> $target/$LogDir/$logfile
	if [ -f /proc/pagetypeinfo ]; then 
		logHeader $target/$LogDir/$logfile "memory : pagetype"
		cp /proc/pagetypeinfo  $target/$LogDir/$memory_dir/pagetypeinfo$extension 2>>$errorlog
		logFooter $target/$LogDir/$logfile "-" $target/$LogDir/$memory_dir
	fi
	
	if [ -x "$(command -v free)" ]; then 
		logHeader $target/$LogDir/$logfile "memory : free,meminfo"
		free --human --lohi --total > $target/$LogDir/$memory_dir/free_cmd$extension
		cp /proc/meminfo  $target/$LogDir/$memory_dir/memory_assigned$extension 2>>$errorlog
		logFooter $target/$LogDir/$logfile " " $target/$LogDir/$memory_dir
	fi 
	
	if [ -x "$(command -v lsmem)" ]; then 
		logHeader $target/$LogDir/$logfile "memory : free,meminfo"
		lsmem --all --output-all > $target/$LogDir/$memory_dir/lsmem$extension
		logFooter $target/$LogDir/$logfile " " $target/$LogDir/$memory_dir
	fi 

	if [ -f /proc/iomem ]; then 
		logHeader $target/$LogDir/$logfile "memory : iomem"
		cp /proc/iomem  $target/$LogDir/$memory_dir/io_memory_address$extension 2>>$errorlog
		logFooter $target/$LogDir/$logfile " " $target/$LogDir/$memory_dir
	fi

	if [ -f /proc/vmalloc ]; then 
		logHeader $target/$LogDir/$logfile "-memory : vmalloc"
		cp /proc/vmalloc  $target/$LogDir/$memory_dir/os-system-version$extension 2>>$errorlog
		logFooter $target/$LogDir/$logfile "-" $target/$LogDir/$memory_dir
	fi

	#AEP Memory section
	if [ -x "$(command -v ipmctl)" ]; then
		logHeader $target/$LogDir/$logfile "-memory : ipmctl"
		ipmctl show -dimm >> $target/$LogDir/$memory_dir/dcpmm_info$extension 2>>$errorlog
		ipmctl show -firmware >> $target/$LogDir/$memory_dir/dcpmm_info$extension 2>>$errorlog
		ipmctl show -topology >> $target/$LogDir/$memory_dir/dcpmm_info$extension 2>>$errorlog
		ipmctl show -system -capabilities >> $target/$LogDir/$memory_dir/dcpmm_info$extension 2>>$errorlog
		ipmctl show -memoryresources >> $target/$LogDir/$memory_dir/dcpmm_info$extension 2>>$errorlog
	#	ipmctl show -d LastShutdownStatus -dimm >> $target/$LogDir/$memory_dir/dcpmm_info$extension 2>>$errorlog
		ipmctl show -Sensor >> $target/$LogDir/$memory_dir/dcpmm_info$extension 2>>$errorlog
		ipmctl show -d HealthState,ManageabilityState,FWVersion -dimm >> $target/$LogDir/$memory_dir/dcpmm_info$extension 2>>$errorlog
		ipmctl show -d bootstatus -dimm  >> $target/$LogDir/$memory_dir/dcpmm_info$extension 2>>$errorlog
		ipmctl show -d modessupported -system -capabilities >> $target/$LogDir/$memory_dir/dcpmm_info$extension 2>>$errorlog
		ipmctl show -event >> $target/$LogDir/$memory_dir/dcpmm_info$extension 2>>$errorlog
		logFooter $target/$LogDir/$logfile "-" $target/$LogDir/$memory_dir
	fi
	logFileStubbSection $target/$LogDir/$logfile $target/$LogDir/$memory_dir/ "- Memory section ends " $memory_dir
}

function get_network_info() {
	#Network section
	echo "- Network section begins" >> $target/$LogDir/$logfile
	if [ -f /proc/net/dev ]; then 
		logHeader $target/$LogDir/$logfile "network : statistics"
		cat /proc/net/dev | column -t > $target/$LogDir/$net_dir/network_devices_stats$extension
		logFooter $target/$LogDir/$logfile "-" $target/$LogDir/$net_dir
	fi

	if [ -x "$(command -v ifconfig)" ]; then 
		logHeader $target/$LogDir/$logfile "network : ifconfig "
		ifconfig  -a -v > $target/$LogDir/$net_dir/ifconfig$extension
		logFooter $target/$LogDir/$logfile " " $target/$LogDir/$net_dir
	fi 

	if [ -x "$(command -v ip)" ]; then 
		logHeader $target/$LogDir/$logfile "network : IP"
		ip  addr show > $target/$LogDir/$net_dir/ip_addr_generic$extension
		ip  route > $target/$LogDir/$net_dir/ip_routes$extension
		logFooter $target/$LogDir/$logfile "-" $target/$LogDir/$net_dir
	fi 

	if [ -f /proc/hosts ]; then 
		logHeader $target/$LogDir/$logfile "network : Hosts"
		cp /etc/hosts $target/$LogDir/$net_dir/network_hosts
		logFooter $target/$LogDir/$logfile "-" $target/$LogDir/$net_dir
	fi

	if [ -x "$(command -v route)" ]; then 
		logHeader $target/$LogDir/$logfile "network : routes"
		route --verbose --extend  > $target/$LogDir/$net_dir/route$extension
		logFooter $target/$LogDir/$logfile "-" $target/$LogDir/$net_dir
	fi

	if [ -x "$(command -v ss)" ]; then 
		logHeader $target/$LogDir/$logfile "network : routes"
		ss --all --info --memory --extended  > $target/$LogDir/$net_dir/route$extension
		logFooter $target/$LogDir/$logfile "-" $target/$LogDir/$net_dir
	fi
	
	logFileStubbSection $target/$LogDir/$logfile $target/$LogDir/$net_dir/ "- Network section ends" $net_dir
}

function get_io_info() {
	#IO section
	echo "- IO section begins " >> $target/$LogDir/$logfile

	if [ -f /proc/ioports ]; then 
		logHeader $target/$LogDir/$logfile "io : ioports"
		cp /proc/ioports  $target/$LogDir/$io_dir/io_ports$extension 2>>$errorlog
		logFooter $target/$LogDir/$logfile "-" $target/$LogDir/$io_dir
	fi 

	if [ -f /proc/softirqs ]; then 
		logHeader $target/$LogDir/$logfile "io : softirqs"
		cp /proc/softirqs  $target/$LogDir/$io_dir/soft_irqs$extension 2>>$errorlog
		logFooter $target/$LogDir/$logfile "-" $target/$LogDir/$io_dir
	fi

	if [ -f /proc/interrupts ]; then 
		logHeader $target/$LogDir/$logfile "io : IRQS"
		cp /proc/interrupts $target/$LogDir/$io_dir/interrupts$extension 2>>$errorlog
		logFooter $target/$LogDir/$logfile "-" $target/$LogDir/$io_dir
	fi

	if [ -x "$(command -v vmstat)" ]; then 
		logHeader $target/$LogDir/$logfile "io : vmstats"
		vmstat --active --wide > $target/$LogDir/$io_dir /vmstats$extension
		vmstat --active --wide --timestamp --stats > $target/$LogDir/$io_dir/vmstats_more$extension 2>>$errorlog
		logFooter $target/$LogDir/$logfile " " $target/$LogDir/$io_dir
	fi 

	logFileStubbSection $target/$LogDir/$logfile $target/$LogDir/$io_dir/ "- IO section ends " $io_dir
}

function get_hw_info() {
	# Hardware logs section
	echo "- Hardware section starts :" >> $target/$LogDir/$logfile

	if [ -x "$(command -v lshw)" ]; then 
		logHeader $target/$LogDir/$logfile "hardware : lshw"
		lshw -html  > $target/$LogDir/$hw_dir/lshw-system-info.html
		lshw -short > $target/$LogDir/$hw_dir/lshw-system-info-brief$extension
		logFooter $target/$LogDir/$logfile "-" $target/$LogDir/$hw_dir/
	fi

	if [ -x "$(command -v hwinfo)" ]; then 
		logHeader $target/$LogDir/$logfile "hardware : hwinfo"
		hwinfo --all --log=$target/$LogDir/$hw_dir/hwinfo$extension
		logFooter $target/$LogDir/$logfile "-" $target/$LogDir/$hw_dir/
	fi

	if [ -x "$(command -v dmidecode)" ]; then 
		logHeader $target/$LogDir/$logfile "hardware : dmidecode"
		dmidecode > $target/$LogDir/$hw_dir/dmidecode-hw$extension
		logFooter $target/$LogDir/$logfile "-" $target/$LogDir/$hw_dir/
	fi


	if [ -x "$(command -v lspci)" ]; then 
		logHeader $target/$LogDir/$logfile "hardware : lspci"
		lspci -t -vv -nn > $target/$LogDir/$hw_dir/lspci-topology$extension
		lspci -vv -x > $target/$LogDir/$hw_dir/lspci-verbose$extension
		logFooter $target/$LogDir/$logfile "-" $target/$LogDir/$hw_dir/
	fi

	if [ -x "$(command -v lscpu)" ]; then 
		logHeader $target/$LogDir/$logfile "hardware : lscpu"
		lscpu > $target/$LogDir/$hw_dir/lscpu-cpu-basic$extension
		lscpu --extended --all --physical | column -t > $target/$LogDir/$hw_dir/lscpu-extended$extension
		logFooter $target/$LogDir/$logfile "-" $target/$LogDir/$hw_dir/
	fi 

	if [ -f /proc/cpuinfo  ]; then 
		logHeader $target/$LogDir/$logfile "hardware : cpuinfo"
		cp /proc/cpuinfo $target/$LogDir/$hw_dir/cpuinfo$extension 2>> $errorlog
		logFooter $target/$LogDir/$logfile "-" $target/$LogDir/$hw_dir/
	fi

	if [ -f /proc/schedstat ]; then 
		logHeader $target/$LogDir/$logfile "hardware : cpu schedule"
		cp /proc/schedstat $target/$LogDir/$hw_dir/cpu_schedule$extension 2>>$errorlog
		logFooter $target/$LogDir/$logfile "-" $target/$LogDir/$hw_dir/
	fi


	if [ -f /var/log/xorg.0$extension ]; then 
		logHeader $target/$LogDir/$logfile "hardware : x-server"
		cp /var/log/xorg.0$extension $target/$LogDir/$hw_dir/xorg$extension 2>> $errorlog
		logFooter $target/$LogDir/$logfile "-" $target/$LogDir/$hw_dir/
	fi


	if [ -f /proc/devices ]; then 
		logHeader $target/$LogDir/$logfile "hardware : devices"
		cp /proc/devices $target/$LogDir/$hw_dir/devices$extension 2>> $errorlog
		logFooter $target/$LogDir/$logfile "-" $target/$LogDir/$hw_dir/
	fi
	
	if [ -x "$(command -v lsusb)" ]; then 
		logHeader $target/$LogDir/$logfile "io : lsusb"
		lsusb --tree > $target/$LogDir/$io_dir/lsusb_topology$extension
		lsusb > $target/$LogDir/$io_dir/lsusb_normal$extension
		lsusb --verbose > $target/$LogDir/$io_dir/lsusb_verbose$extension
		logFooter $target/$LogDir/$logfile "-" $target/$LogDir/$io_dir
	fi

	logFileStubbSection $target/$LogDir/$logfile $target/$LogDir/$hw_dir/ "- hardware section end " $hw_dir

}

function get_fs_info() {
	# Storage logs section
	echo "- Storage section begins " >> $target/$LogDir/$logfile
	if [ -x "$(command -v lsblk)" ]; then 
		logHeader $target/$LogDir/$logfile "storage : lsblk"
		lsblk --all --ascii --perms --fs --topology | column --table  > $target/$LogDir/$storage_dir/lsblk-verbose$extension
		logFooter $target/$LogDir/$logfile "-" $target/$LogDir/$storage_dir/
	fi 

	if [ -x "$(command -v lsscsi)" ]; then 
		logHeader $target/$LogDir/$logfile "storage : lsscsi"
		lsscsi --size --verbose --list --long --size  > $target/$LogDir/$storage_dir/lssci-verbose$extension
		logFooter $target/$LogDir/$logfile "lsscsi" $target/$LogDir/$storage_dir/
	fi

	if [ -x "$(command -v fdisk)" ]; then 
		logHeader $target/$LogDir/$logfile "storage : fdisk"
		fdisk --list > $target/$LogDir/$storage_dir/fdisk-listed$extension
		logFooter $target/$LogDir/$logfile "-" $target/$LogDir/$storage_dir/
	fi

	if [ -x "$(command -v df)" ]; then 
		logHeader $target/$LogDir/$logfile "storage : df"
		df --human-readable --all > $target/$LogDir/$storage_dir/df-stats$extension
		logFooter $target/$LogDir/$logfile "-" $target/$LogDir/$storage_dir/
	fi

	if [ -f /proc/partitions  ];then 
		logHeader $target/$LogDir/$logfile "storage : partition file"
		cp /proc/partitions $target/$LogDir/$storage_dir/partitions$extension 2>> $errorlog
		logFooter $target/$LogDir/$logfile "-" $target/$LogDir/$storage_dir/
	fi

	if [ -x "$(command -v mount)" ]; then 
		logHeader $target/$LogDir/$logfile "storage : mount"
		mount --verbose --show-labels | column --table > $target/$LogDir/$storage_dir/mounted_fs$extension
		logFooter $target/$LogDir/$logfile "-" $target/$LogDir/$storage_dir/
	fi

	if [ -f /proc/scsi  ]; then 
		logHeader $target/$LogDir/$logfile "storage : scsi"
		cp /proc/scsi/scsi $target/$LogDir/$storage_dir/scsi_devices$extension 2>>$errorlog
		logFooter $target/$LogDir/$logfile "-" $target/$LogDir/$storage_dir/
	fi

	if [ -f /proc/scsi/mounts ]; then 
		logHeader $target/$LogDir/$logfile "storage : scsi-mounts"
		cp /proc/scsi/mounts  $target/$LogDir/$storage_dir/scsi-mounts$extension 2>>$errorlog
		logFooter $target/$LogDir/$logfile "-" $target/$LogDir/$storage_dir/
	fi

	if [ -f /proc/diskstats ]; then 
		logHeader $target/$LogDir/$logfile "storage : diskstats"
		cat /proc/diskstats | column --table >> $target/$LogDir/$storage_dir/diskstats$extension
		logFooter $target/$LogDir/$logfile "-" $target/$LogDir/$storage_dir/
	fi

	if [ -f /proc/filesystems ]; then 
		logHeader $target/$LogDir/$logfile "storage : filesystems"
		cp /proc/filesystems  $target/$LogDir/$storage_dir/fs_systems$extension 2>>$errorlog
		logFooter $target/$LogDir/$logfile "-" $target/$LogDir/$storage_dir/
	fi


	if [ -x "$(command -v blockdev)" ]; then 
		logHeader $target/$LogDir/$logfile "storage : blockdev"
		blockdev --report  |  column --table >> $target/$LogDir/$storage_dir/block_devices$extension
		logFooter $target/$LogDir/$logfile "-" $target/$LogDir/$storage_dir/
	fi

	if [ -x "$(command -v swapon)" ]; then 
		logHeader $target/$LogDir/$logfile "storage : swaps"
		swapon --verbose --show=NAME,TYPE,SIZE,USED,PRIO,UUID,LABEL >> $target/$LogDir/$storage_dir/swapon_stats$extension
		logFooter $target/$LogDir/$logfile "-" $target/$LogDir/$storage_dir/
	fi
	logFileStubbSection $target/$LogDir/$logfile $target/$LogDir/$storage_dir/ "- Storage section ends " $storage_dir
}


function get_other_info(){
	if [ -x "$(command -v selview)" ]; then 
		logHeader $target/$LogDir/$logfile "Selview"
		selview /save $target/$LogDir/sut_$(date +%Y_%m_%d_%H_%M_%S).sel  1>>$errorlog
		selview /save /hex $target/$LogDir/sut_$(date +%Y_%m_%d_%H_%M_%S)_hex.sel 1>>$errorlog
		logFooter $target/$LogDir/$logfile "-" $target/$LogDir/
	fi
}

function tool_usage () {
	echo "Tool to gather Linux OS information for testing cases or debug/triage"
	echo " Usage : $0"
	echo "Type : $0 with more than one argument to get this help."
	exit 1
}

function check_admin() {
	echo "Checking for root or admin credentials"
	if [ "$EUID" -ne 0 ]
	then 
		echo "Please run this script as root."
		exit 
	else 
		echo "Looks Ok, .... continue"
	fi
}

function check_binaries () {
	echo "Check for bin directory ...."
	# Checking this does not hurt
	if [ -d  "/bin" ]
	then 
		echo "main directory BIN is present continue ..." >> $target/$LogDir/$logfile
		echo "Seems ok, continue ...."
	else
		echo "BIN directory is not present at // bailing out..." >> $target/$LogDir/$errorlog
		exit 1
	fi
}

# ======================main(1) Start here :=====================================
# Setting for a future command line checkup
if  [ $# -ne 0 ]
then
	tool_usage 
fi
check_admin

echo "Detecting OS ....."
#Linux distro detection
OS_detect
# setting folders and files ...
script_setup

pause
# Get rid of all the term clutter
clear
# A nice introduction ....
systembanner
# Annnnd proceed with the script ...`
echo "- Starting the recolletion " >> $target/$LogDir/$logfile
echo "- Process started at $(date +%Y:%m:%d:%H:%M:%S) " >> $target/$LogDir/$logfile

logHTMLHeader

#
get_hw_info
#
get_io_info
#
get_fs_info
#
get_memory_info
#
get_network_info
#
get_other_info
#
get_power_info
#
get_process_info
#
get_sys_info



logHTMLFooter
# end 
echo "Script is done, you may want to check the logs on ${LogDir} "
echo "End time : " >> $target/$LogDir/$logfile
date  >> $target/$LogDir/$logfile
exit
