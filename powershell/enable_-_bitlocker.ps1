# Scriptname : bitlocker feature enabler
# Purpose    : install bitlocker feature 
# Created on : 12-28-2018 
# Version    : 0.0.1
# Helps on   :
#            : TC - 44800: DV - TPM - Bitlocker - BitLocker Functional"

$version="0.0.1"

#BitLocker Feature Installer

function BlockerEnable ()
{
    Clear-Host
    Write-Host "---------------------------------------------------------"
    Write-Host "Bitlocker feature will be installed on $env:COMPUTERNAME"
    Write-Host "Save all logs, documents and close any non required program"
    Write-Host "Please wait until installer is done working, the system should rebooot by itself"
    Write-Host "if not, please reboot manually."
    Write-Host "script : $version"
    Read-Host -Prompt "Press enter to continue "

    Add-WindowsFeature Bitlocker -IncludeAllSubFeature -IncludeManagementTools -Restart
}

# Main

BlockerEnable
