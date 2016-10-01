::
::============================================================================
::	File          : all test bat
::	Date          : Sept 27 2016
::	Program name  : all test sanity app batch file
::	Version       : 0.0.1
::	Author        : ----
::	Enviroment    : CLI- Command Terminal for Windows
::	Description   : A simple benchmarking program, only uses
::	basic operations, no reports to file, only console output
::	Notes         : revised in february 28
::============================================================================
::




@echo off
@cls

:: C:
:: cd sanity
::


set titletext=Sanity Tool batch
color 07
title %titletext%
mode con cols=128 lines=64

@echo -------------------------------------------------------
@echo  Running batch of tests for Sanity tool
@echo  Remember to check if Hibernation is enabled on platform
@echo -------------------------------------------------------



set basicdispclone=Basic_display_clone_mode
set basicdispextend=Basic_display_Extended_mode
set OPMTest=OPM_Test
set PAVPTest=PAVP_Test
set S3Test=S3_Test
set S4Test=S4_Test
set S3S4Test=S3_S4_Test
set WIDITest=WIDI_Test
set TextExtension=.txt
set ResultFolder="Results Sanity"
set EDP=edp
set HDMI=hdmi
set DP=dp

:start

@echo -------------------------------------------------------
@echo Test %basicdispclone% started at %time%
Sanity.exe %EDP% %DP% Basic_display_clone_mode
call :STEP 12
timeout 2
@echo Test ended at %time%

@echo -------------------------------------------------------
@echo Test %basicdispextend% started at %time%
Sanity.exe %EDP% %DP% Basic_display_Extended_mode
@echo Test ended at %time%
call :STEP 24
timeout 2

@echo -------------------------------------------------------
@echo Test %OPMTest% started at %time%
Sanity.exe %DP% OPM_Test
@echo Test ended at %time%
call :STEP 32
timeout 2

@echo -------------------------------------------------------
@echo Test %PAVPTest% started at %time%
Sanity.exe %EDP% %DP% PAVP_Test
@echo Test ended at %time%
call :STEP 48
timeout 2

@echo -------------------------------------------------------
@echo Test %S3Test% started at %time%
Sanity.exe %EDP% %DP% S3_Test
@echo Test ended at %time%
call :STEP 64
timeout 2

@echo -------------------------------------------------------
@echo Test %S4Test% started at %time%
Sanity.exe %EDP% %DP% S4_Test
@echo Test ended at %time%
call :STEP 76
timeout 2

@echo -------------------------------------------------------
@echo Test %S3S4Test% started at %time%
Sanity.exe %EDP% %DP% S3_S4_Test
@echo Test ended at %time%
call :STEP 88
timeout 2

@echo -------------------------------------------------------
@echo Test %WIDITest% started at %time%
Sanity.exe %DP% WIDI_Test
@echo Test ended at %time%
call :STEP 100
timeout 2

mode con cols=128 lines=64
@cls
@echo Main tests ended, searching results ...

cd %USERPROFILE%\Desktop

if EXIST %ResultFolder% (
cd %ResultFolder%
) else (
@echo The folder %ResultFolder% was not found! Check if the tool ended its job or run it again.
goto QUIT
)

if EXIST %basicdispclone%%TextExtension% (
@echo %basicdispclone%%TextExtension% found! Here are the results :
type %basicdispclone%%TextExtension% | find "Pass"
@echo -------------------------------------------------------
) ELSE (
@echo %basicdispclone%%TextExtension% was not found
)


if EXIST %basicdispextend%%TextExtension% (
@echo %basicdispextend%%TextExtension% found! Here are the results :
type %basicdispextend%%TextExtension% | find "Pass"
@echo -------------------------------------------------------
) ELSE (
@echo %basicdispextend%%TextExtension% was not found
)


if EXIST %OPMTest%%TextExtension% (
@echo %OPMTest%%TextExtension% found! Here are the results :
type %OPMTest%%TextExtension% | find "Pass"
@echo -------------------------------------------------------
) ELSE (
@echo %OPMTest%%TextExtension% was not found
)

if EXIST %PAVPTest%%TextExtension% (
@echo %PAVPTest%%TextExtension% found! Here are the results :
type %PAVPTest%%TextExtension% | find "Pass"
@echo -------------------------------------------------------
) ELSE (
@echo %PAVPTest%%TextExtension% was not found
)

if EXIST %S3Test%%TextExtension% (
@echo %S3Test%%TextExtension% found! Here are the results :
type %S3Test%%TextExtension% | find "Pass"
@echo -------------------------------------------------------
) ELSE (
@echo %S3Test%%TextExtension% was not found
)

if EXIST %S4Test%%TextExtension% (
@echo %S4Test%%TextExtension% found! Here are the results :
type %S4Test%%TextExtension% | find "Pass"
@echo -------------------------------------------------------
) ELSE (
@echo %S4Test%%TextExtension% was not found
)

if EXIST  %S3S4Test%%TextExtension% (
@echo  %S3S4Test%%TextExtension% found! Here are the results :
type  %S3S4Test%%TextExtension% | find "Pass"
@echo -------------------------------------------------------
) ELSE (
@echo  %S3S4Test%%TextExtension% was not found
)

if EXIST %WIDITest%%TextExtension% (
@echo %WIDITest%%TextExtension% found! Here are the results :
type %WIDITest%%TextExtension% | find "Pass"
@echo -------------------------------------------------------
) ELSE (
@echo %WIDITest%%TextExtension% was not found
)

goto QUIT

:STEP
title %titletext% %1% %% Completed


:QUIT
color 07
cd ..
timeout 3
exit /b
