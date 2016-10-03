::
::============================================================================
::	File          : all test bat
::	Date          : Sept 27 2016
::	Program name  : all test sanity app batch file
::	Version       : 0.0.1
::	Author        : ----
::	Enviroment    : CLI- Command Terminal for Windows
::	Description   :
::
::	Notes         : only executes the sanity tool, must be copied into the same
::	folder to work.
::============================================================================
::

@echo off
@cls

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
set sanity_tool=Sanity.exe

:start

@echo -------------------------------------------------------
@echo Test %basicdispclone% started at %time%
%sanity_tool% %EDP% %DP% Basic_display_clone_mode

timeout 2
@echo Test ended at %time%

@echo -------------------------------------------------------
@echo Test %basicdispextend% started at %time%
%sanity_tool% %EDP% %DP% Basic_display_Extended_mode
@echo Test ended at %time%

timeout 2

@echo -------------------------------------------------------
@echo Test %OPMTest% started at %time%
%sanity_tool% %DP% OPM_Test
@echo Test ended at %time%

timeout 2

@echo -------------------------------------------------------
@echo Test %PAVPTest% started at %time%
%sanity_tool% %EDP% %DP% PAVP_Test
@echo Test ended at %time%

timeout 2

@echo -------------------------------------------------------
@echo Test %S3Test% started at %time%
%sanity_tool% %EDP% %DP% S3_Test
@echo Test ended at %time%

timeout 2

@echo -------------------------------------------------------
@echo Test %S4Test% started at %time%
%sanity_tool% %EDP% %DP% S4_Test
@echo Test ended at %time%

timeout 2

@echo -------------------------------------------------------
@echo Test %S3S4Test% started at %time%
%sanity_tool% %EDP% %DP% S3_S4_Test
@echo Test ended at %time%

timeout 2

@echo -------------------------------------------------------
@echo Test %WIDITest% started at %time%
%sanity_tool% %DP% WIDI_Test
@echo Test ended at %time%

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



:QUIT
color 07
timeout 3
exit /b
