# Scriptname : eventlog saver
# Purpose    : get system event log and save to a file
# Created on : 12-28-2018 
# Version    : 0.0.1

# var setup
$version="0.0.1"
$systemlog="system-log.csv"
$applicationlog="application.csv"
$setuplog="setup.csv"
$userselection=0
$savefolder="events_$(Get-Date -Format yyyy_MM_HH_ss)"
$summaryfile="summary.txt"
$menu= "Save Events", "Erase event logs", "Quit"

# Saving logs
function event_saver()
{
    Write-Host "Windows event saver"
    Write-Host "The next system logs will be saved :" 
    Write-Host "Saving System event to CSV, please wait ..." 
    Get-EventLog -LogName "System" -ErrorAction SilentlyContinue | Export-Csv $savefolder/$systemlog
    Write-Host "Saving application  to CSV, please wait"
    Get-EventLog -LogName "Application" -ErrorAction SilentlyContinue | Export-Csv $savefolder/$applicationlog
    Write-Host "Saving Setup log events to CSV"
    Get-EventLog -LogName "Setup" -ErrorAction SilentlyContinue | Export-Csv $savefolder/$setuplog
    Write-Host "Application, System and Setup logs are saved, plase view inside the '$savefolder' folder " 
    Read-Host -Prompt "Press enter to continue " 
}


#erasing logs
function event_eraser()
{
    Write-Host "Windows event eraser"
    Write-host "The next logs will be erased :"
    Write-host "Erasing System events"
    Clear-EventLog -LogName System
    Write-Host "Erasing Application events"
    Clear-EventLog -LogName Application
    Read-Host -Prompt "Press enter to continue " 
}

# Create the folder
New-Item -Path "./" -Type Directory -Name $savefolder -Force
Get-Date | Add-Content $savefolder/$summaryfile

while ($userselection -ne 2)
{
    Clear-Host
    

    Write-Host "Event save tool "
    for ($i = 0; $i -lt $menu.Length; $i++)
    {
        Write-Host "$i" $menu[$i]
    }

    $userselection = Read-Host -Prompt "Type you selection"

    switch($userselection)
    {
        0 
        {
            event_saver;
            break
        }
        1
        {
            event_eraser;
            break        
        }
    }

}



