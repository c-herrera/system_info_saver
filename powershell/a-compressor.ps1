#    File     : auto folder compressor
#    Purpose  : compress and zip all folders unto one single file
#    Requires : external tool  7-zip
#    Revision : 0.0.1


#var setup

$tool="7z.exe"
$tool_folder=""
$archive_arg='a'
$target_folders=""
$wtf=""
#main

#Clear-Host


if (Test-Path -Path "$env:ProgramFiles\7-Zip" -IsValid)
{
    Write-Host "Progrmm folder found, continue"
    $tool_folder = "$env:ProgramFiles\7-Zip\7z.exe"

    if (Test-Path -Path $tool_folder -PathType Leaf)
    {
        Write-Host "File found!"
    }
    else
    {
        Write-Host "Opps"
        return
    }
}
else
{
    Write-Host "Tool not found, please install 7 zip and run again"
}


Write-Host "Starting batch compression at " $(Get-Date)
Write-Host "Target folder is " (Get-Location) ", from this folder, these are the targets"
Get-ChildItem -Directory | Format-Table -AutoSize

$target_folders = Get-ChildItem -Directory -Name


foreach ($folder in $target_folders)
{
    Write-Host "Creating compressed file from folder "  $folder.Trim()
    Start-Process   -FilePath "$tool_folder" -ArgumentList "a", (Get-Location | Get-ChildItem -Directory)  -RedirectStandardError "error.txt" -NoNewWindow -Verbose -Debug -Wait -RedirectStandardOutput "std.txt"
    #Write-Host " $tool_folder\7z.exe  $folder"
}

Write-Host "w" $wtf