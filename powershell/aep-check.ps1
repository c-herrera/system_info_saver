# Scriptname : AEP Dimm Reports
# Purpose    : Run main check
# Created on : 12-28-2018 
# Version    : 0.0.1
# 

$ipmctlbin = $env:ProgramFiles + '\Intel\DCPMM Software'
$logfile = "aep-summary.txt"

Write-Host $ipmctlbin
Test-Path $ipmctlbin

Write-Host "[Health.check]"

Set-Location $env:ProgramFiles
Set-Location ".\Intel"
Set-Location .\DCPMM \Software

Write-Host " - Show Device"
./ipmctl.exe show -dimm  |  Tee-Object -Append $logfile



echo - Show Device; Attribute BootStatus
ipmctl show -d LastShutdownStatus -dimm

echo - Show Mode Supported
ipmctl show -d modessupported -system -capabilities

echo - Show Topology
ipmctl show -topology


echo - Show Memory Resources
ipmctl show -memoryresources


echo -Show System Capabilities
ipmctl show -system -capabilities


echo -Show Sensor (Media Temperature)
ipmctl show -Sensor

echo - Heatlh check
ipmctl show -d HealthState,ManageabilityState,FWVersion -dimm

echo -Show firmware
ipmctl show -dimm -firmware

echo -Show Device - Attribute BootStatus 
ipmctl show -d bootstatus -dimm 

echo [Memory-allocation]
echo -Show the memory allocation goal on one or more DCPMMs
ipmctl show -goal

echo [Memory Config]
echo -Store the currently configured memory allocation settings for all DCPMMs
ipmctl dump -destination config.csv -system -config
