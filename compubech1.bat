::	File     : compubench helper
::	Purpose  : runs compubench mobile
::	Revision : 0
::	Version  : 0.1
::	
::	Notes : 
SetLocal EnableDelayedExpansion EnableExtensions
@echo off
@cls
set testExeName=
set version=0.0.1
set input=0

@echo -----------------------------------------------
@echo Type the number of the focused test executable :
@echo [1] Kishonti Compubench Mobile (CLI)
@echo [2] Kishonti Compubench Desktop`
@echo [9] Exit

set /p input="Type the number of the test to run :"

@echo --- %input%


if /I "%input%"=="1" goto compubenchMobile
if /I "%input%"=="2" goto compubenchDesktop
if /I "%input%"=="9" goto quit


:compubenchMobile
set testExeName=CompubenchMobile_CLI_log.txt

@echo off
@echo Compubench-Mobile-CLI Test
@echo Test Start
@echo ============================================================
@echo Face detect Test
@timeout 2 > nul
Compubench-Mobile-CLI.exe --gfx=glfw --test_id=cl_facedetect_buff >> %testExeName%
@pause
@echo ============================================================
@echo Face detect Test 2
@timeout 2 > nul
Compubench-Mobile-CLI.exe --gfx=glfw --test_id=cl_facedetect_img >> %testExeName%
@pause
@echo ============================================================
@echo Fluid 32k Test
@timeout 2 > nul
Compubench-Mobile-CLI.exe --gfx=glfw --test_id=cl_fluid_32k >> %testExeName%
@pause
@echo ============================================================
@echo Fractal Julia Test
@timeout 2 > nul
Compubench-Mobile-CLI.exe --gfx=glfw --test_id=cl_fractal_juliaset >> %testExeName%
@pause
@echo ============================================================
@echo Gauss Buffered Test
@timeout 2 > nul
Compubench-Mobile-CLI.exe --gfx=glfw --test_id=cl_gauss_buff >> %testExeName%
@pause
@echo ============================================================
@echo Gauss Image Test
@timeout 2 > nul
Compubench-Mobile-CLI.exe --gfx=glfw --test_id=cl_gauss_img >> %testExeName%
@pause
@echo ============================================================
@echo Histogram Test
@timeout 2 > nul
Compubench-Mobile-CLI.exe --gfx=glfw --test_id=cl_histogram_buff >> %testExeName%
@pause
@echo ============================================================
@echo Face detect Test
@timeout 2 > nul
Compubench-Mobile-CLI.exe --gfx=glfw --test_id=cl_histogram_img >> %testExeName%
@pause
@echo ============================================================
@echo Face detect Test
@timeout 2 > nul
Compubench-Mobile-CLI.exe --gfx=glfw --test_id=cl_raytrace_ambocc >> %testExeName%
@pause
@echo ============================================================
@echo Face detect Test
@timeout 2 > nul
Compubench-Mobile-CLI.exe --gfx=glfw --test_id=cl_raytrace_raycast >> %testExeName%
@pause
goto quit

:compubenchDesktop
set testExeName=CompubenchDesktop_CLI_log.txt

@echo off
@echo Compubench-Desktop-CLI Test
@echo Test Start
@echo ============================================================
goto quit

:quit
@echo ============================================
@echo Done with batch, no more operations from this point on.
@echo Script : %0% 
@echo version : %version%
@echo ============================================
exit /b