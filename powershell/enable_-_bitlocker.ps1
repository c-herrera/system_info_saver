# Scriptname : bitlocker feature enabler
# Purpose    : install bitlocker feature 
# Created on : 12-28-2018 
# Version    : 0.0.1
# Helps on   :
#            : Enable Bitlocker


# var setup
$systemlog="system-log.csv"
$applicationlog="application.csv"
$userselection=0
$main_folder="events"
$savefolder="install_bitlocker_$(Get-Date -Format yyyy_dd_MM_HH_ss)"
$summaryfile="summary.txt"

$userkb_in=-1
$version="0.0.1"
$menu = "Install Bitlocker Feature" ," Do not install it"

# Saving logs
function event_saver()
{
    Write-Host "The next system logs will be saved :" 
    Write-Host "System events to CSV, please wait ..." 
    Get-EventLog -LogName "System" -ErrorAction SilentlyContinue | Export-Csv $main_folder/$savefolder/$systemlog
    Write-Host "Application events to CSV, please wait"
    Get-EventLog -LogName "Application" -ErrorAction SilentlyContinue | Export-Csv $main_folder/$savefolder/$applicationlog
    Write-Host "Application, System and Setup logs are saved, plase view inside the '$savefolder' folder " | Add-Content
    Read-Host -Prompt "Press enter to continue " 
}



#BitLocker Feature Installer

function BitlockerEnable ()
{
    Clear-Host
    Write-Host "---------------------------------------------------------"
    Write-Host "Bitlocker feature will be installed on $env:COMPUTERNAME"
    Write-Host "Save all logs, documents and close any non required program"
    Write-Host "Please wait until installer is done working, the system should rebooot by itself"
    Write-Host "if not, please reboot manually."
    Write-Host "script : $version"

    #Add-WindowsFeature Bitlocker -IncludeAllSubFeature -IncludeManagementTools -Restart
    Read-Host -Prompt "Press enter to continue "
}

# Main

# Create the folder
New-Item -Path "./" -Type Directory -Name $main_folder -Force
New-Item -Path "./" -Type Directory -Name $main_folder/$savefolder
Get-Date | Add-Content $main_folder/$savefolder/$summaryfile


while ($userkb_in -ne 1)
{
    Clear-Host

    for ($i = 0; $i -lt $menu.Length; $i++)
    {
        Write-Host "$i" $menu[$i]
    }
    $userkb_in= Read-Host -Prompt "Type your selection "
    switch($userkb_in)
    {
        0
        {
            BitlockerEnable
            event_saver
            break
        }
        1
        {     
            $userkb_in=1       
            break
        }

    }
}



