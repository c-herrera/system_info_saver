::	File     : compressor1.bat
::	Purpose  : Compress all folders to zip files using 7 zip
::	Revision : 0
::	Version  : 0.1
::	
::	Notes : Script assumes to have installed 7 zip it check for it at startup, though
SetLocal EnableDelayedExpansion EnableExtensions
@echo off
@cls

set zipfolder=
set zipapp=7z.exe
set version=0.0.1
set is_ok=

:: Look for 64 Program Files
if exist %ProgramFiles% (
	if exist %ProgramFiles%\7-Zip\7z.exe (
		set zipfolder=%ProgramFiles%\7-Zip\7z.exe
		@echo Folder is %zipfolder%
		goto have7zip
	) else goto failure
)  

if exist %ProgramFiles(x86)% (
	if exist %ProgramFiles(x86)%\7-Zip\7z.exe (
		set zipfolder=%ProgramFiles(x86)%\7-Zip\7z.exe
		@echo Folder is %zipfolder%
		goto have7zip
	) else goto failure
) 

:have7zip
@echo ------------------------------------------------
@echo Starting batch compression at %date%-%time%
@echo Using 7 zip to compress the next folders in %CD%
@echo ------------------------------------------------ 
@dir /d
@echo ------------------------------------------------ 
for /d %%X in (*) do ( 
	@echo ============================================
	@echo Creating "%%X.zip" from "%%X\"
	@echo ============================================
	REM "c:\Program Files\7-Zip\7z.exe" a "%%X.zip" "%%X\"
	"%zipfolder%" a "%%X.zip" "%%X\"
	if ERRORLEVEL == 1 goto failure
) 

@echo Done!
goto Quit

:failure
@echo xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
@echo An error has ocurred
goto Quit

:Quit
@echo ============================================
@echo Done with batch, no more operations from this point on.
@echo Script : %0% 
@echo version : %version%
@echo ============================================
exit /b
