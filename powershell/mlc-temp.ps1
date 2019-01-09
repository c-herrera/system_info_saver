#

Clear-Host
Write-Host "Erasing System logs ...."
Clear-EventLog -LogName System
Clear-EventLog -LogName Application

Write-Host "Pmem info" 
Get-PmemDisk
Read-Host -Prompt "Press enter to continue"
Write-Host "Running MLC Performance" 
.\mlc_avx512.exe | Tee-Object 1lm_mlc.out

Read-Host -Prompt "Press enter to continue"

Write-Host "Running MLC Latency"
.\mlc_avx512.exe --idle_latency -c0 -JE: | Tee-Object 1lm_latency.log

Read-Host -Prompt "Press enter to continue"

.\mlc_avx512.exe --idle_latency -c0 -JF: | Tee-Object 1lm_latency.log






