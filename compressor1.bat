::	File     : compressor1.bat
::	Purpose  : Compress all folders to zip files using 7 zip
::	Revision : 0
::	Version  : 0.1
::	
::	Notes : Script assumes to have installed 7 zip it check for it at startup, though
SetLocal EnableDelayedExpansion EnableExtensions
@echo off
@cls
set 7zip_folder=
set 7zip_app=7z.exe
set is_ok=

@pause

if exist "c:\Program Files\7-Zip\7z.exe" (
	REM set 7zip_folder="c:\Program Files\7-Zip\7z.exe"
	REM @echo f %7zip_folder%
	set is_ok="true"
)  

if exist "c:\Program Files (x86)\7-Zip\7z.exe" (
	@echo 2
	REM set 7zip_folder=""c:\Program Files (x86)\7-Zip\7z.exe"
	set is_ok="true"
) 

if /b "%is_ok%"=="true" (
	goto have7zip
) else (
	goto failure
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
 "c:\Program Files\7-Zip\7z.exe" a "%%X.zip" "%%X\"
REM %7zip_folder% a "%%X.zip" "%%X\"
) 
@echo Done!
:failure
@echo An error has ocurred