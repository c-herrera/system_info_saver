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

