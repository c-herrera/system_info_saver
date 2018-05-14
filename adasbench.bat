::	File     : 
::	Purpose  : 
::	Revision : 0.0.1 ( Pre )
::	EOL      : TDB
::	Notes    : 
::			
::			

@echo off
SetLocal EnableDelayedExpansion EnableExtensions
@cls

set testname=
set input=

@echo +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
@echo Running AdasBench ADAS 2
@echo +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
@echo Running first set of tests, 
@echo Please have already your test setup ready before continue 
@echo (Connect all displays from test grid, Power Plan as test procedures)
pause
@echo +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
set testname=Drownsiness
@echo Running %testname%
ADASBench-ADAS2-CLI.exe --gfx=glfw --test_id=cl_drowsiness
pause
@echo +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
set testname=Composite
@echo Running %testname%
ADASBench-ADAS2-CLI.exe --gfx=glfw --test_id=cl_composite
pause
@echo +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
set testname=NN_HighRes
@echo Running %testname%
ADASBench-ADAS2-CLI.exe --gfx=glfw --test_id=cl_nn_highres 
pause
@echo +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
set testname=NN_Lowres
@echo Running %testname%
ADASBench-ADAS2-CLI.exe --gfx=glfw --test_id=cl_nn_lowres 
pause
@echo +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
set testname=NN_Midres
@echo Running %testname%
ADASBench-ADAS2-CLI.exe --gfx=glfw --test_id=cl_nn_midres 
pause
@echo +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
set testname=Surround_View_1MP
@echo Running %testname%
ADASBench-ADAS2-CLI.exe --gfx=glfw --test_id=cl_surround_view_1MP
pause
@echo +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
set testname=Surround_View_2MP
@echo Running %testname%
ADASBench-ADAS2-CLI.exe --gfx=glfw --test_id=cl_surround_view_2MP
pause

@echo End of first batch.
set /p input="Continue Y/N?"
if /i "%input%"=="N" goto Quit


@echo +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
@echo Running second set of tests, 
@echo Please have already your test setup ready before continue 
@echo (Connect all displays from test grid, Power Plan as test procedures)
pause
@echo +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
set testname=Drownsiness
@echo Running %testname%
ADASBench-ADAS2-CLI.exe --gfx=glfw --test_id=cl_drowsiness
pause
@echo +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
set testname=Surround_View_1MP
@echo Running %testname%
ADASBench-ADAS2-CLI.exe --gfx=glfw --test_id=cl_surround_view_1MP
pause
@echo +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
set testname=Surround_View_2MP
@echo Running %testname%
ADASBench-ADAS2-CLI.exe --gfx=glfw --test_id=cl_surround_view_2MP
pause

@echo End of second batch.
set /p input="Continue Y/N?"
if /i "%input%"=="N" goto Quit


ADASBench-ADAS2-CLI.exe --gfx=glfw --test_id=cl_drowsiness
pause
ADASBench-ADAS2-CLI.exe --gfx=glfw --test_id=cl_composite
pause
ADASBench-ADAS2-CLI.exe --gfx=glfw --test_id=cl_nn_highres 
pause
ADASBench-ADAS2-CLI.exe --gfx=glfw --test_id=cl_surround_view_2MP
pause




ADASBench-ADAS2-CLI.exe --gfx=glfw --test_id=cl_nn_lowres 
pause
ADASBench-ADAS2-CLI.exe --gfx=glfw --test_id=cl_nn_midres 
pause
ADASBench-ADAS2-CLI.exe --gfx=glfw --test_id=cl_surround_view_1MP
pause


ADASBench-ADAS2-CLI.exe --gfx=glfw --test_id=cl_drowsiness
pause
ADASBench-ADAS2-CLI.exe --gfx=glfw --test_id=cl_nn_lowres 
pause
ADASBench-ADAS2-CLI.exe --gfx=glfw --test_id=cl_nn_midres 
pause
ADASBench-ADAS2-CLI.exe --gfx=glfw --test_id=cl_surround_view_1MP
pause


ADASBench-ADAS2-CLI.exe --gfx=glfw --test_id=cl_drowsiness
pause
ADASBench-ADAS2-CLI.exe --gfx=glfw --test_id=cl_composite
pause
surrownd_view_2MP 
pause


:Quit
@echo +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
@echo End of script.
@echo Script ver : %scrp_ver%
@echo script name : %0
@echo +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++