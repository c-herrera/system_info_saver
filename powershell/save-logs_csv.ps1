# Scriptname : eventlog saver
# Purpose    : get system event log and save to a file
# Created on : 12-28-2018 
# Version    : 0.0.1
# Helps on   :
#            : Save windows system and application event logs

# var setup
$version="0.0.1"
$systemlog="system-log.csv"
$applicationlog="application.csv"
$setuplog="setup.csv"
$userselection=0
$main_folder="events"
$savefolder="event_logs_$(Get-Date -Format yyyy_dd_MM_HH_ss)"
$summaryfile="summary.txt"
$quit=0
$menu= "Save Events", "Erase event logs", "Save system info","Quit"

# Saving logs
function event_saver()
{
    Write-Host "Windows event saver :" 
    Write-Host "Running on date " (Get-Date) 
    Write-Host "Saving System event to CSV, please wait ..." 
    Get-EventLog -LogName "System" -ErrorAction SilentlyContinue | Export-Csv $main_folder/$savefolder/$systemlog
    Write-Host "Saving application  to CSV, please wait"
    Get-EventLog -LogName "Application" -ErrorAction SilentlyContinue | Export-Csv $main_folder/$savefolder/$applicationlog
    Write-Host "Application, System and Setup logs are saved, please view inside the '$savefolder' folder " 
    Read-Host -Prompt "Press enter to continue "     
}


#erasing logs
function event_eraser()
{
    Write-Host "Windows event eraser :" 
    Write-host "Running on date :" (Get-Date) 
    Write-host "Erasing System events"
    Clear-EventLog -LogName System
    Write-Host "Erasing Application events"
    Clear-EventLog -LogName Application
    Write-Host "Event logs erased on "  (Get-Date) 
    Read-Host -Prompt "Press enter to continue " 
}

#Get system info

function saveSystemInfo()
{
    Write-host "Saving Windows system info"
    Write-Host "Running on date :" (Get-Date)
    Get-ComputerInfo -Verbose | Tee-Object $main_folder/$savefolder/Windowssysteminfo.txt
}



# Create the folder
New-Item -Path "./" -Type Directory -Name $main_folder -Force
New-Item -Path "./" -Type Directory -Name $main_folder/$savefolder
Get-Date | Add-Content $main_folder/$savefolder/$summaryfile

while ($userselection -ne $quit)
{
    Clear-Host
    

    Write-Host "Event save tool "
    for ($i = 0; $i -lt $menu.Length; $i++)
    {
        Write-Host "$i" $menu[$i]
        $quit=($i).ToInt32()
    }

    $userselection = Read-Host -Prompt "Type you selection"

    switch($userselection)
    {
        0 
        {
            event_saver 
            break
        }
        1
        {
            event_eraser 
            break        
        }
        2
        {
            saveSystemInfo
            break
        }
    }

}



