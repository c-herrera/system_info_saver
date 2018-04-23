::	File     : compubench helper
::	Purpose  : runs compubench mobile
::	Revision : 0
::	Version  : 0.1
::	
::	Notes : 
SetLocal EnableDelayedExpansion EnableExtensions
@echo off
@cls

set version=0.0.1

@echo off
@echo Compubench-Mobile-CLI Test
@echo Test Start
@echo ============================================================
@echo Face detect Test
@timeout 2 > nul
Compubench-Mobile-CLI.exe --gfx=glfw --test_id=cl_facedetect_buff 
@pause
@echo ============================================================
@echo Face detect Test 2
@timeout 2 > nul
Compubench-Mobile-CLI.exe --gfx=glfw --test_id=cl_facedetect_img 
@pause
@echo ============================================================
@echo Fluid 32k Test
@timeout 2 > nul
Compubench-Mobile-CLI.exe --gfx=glfw --test_id=cl_fluid_32k 
@pause
@echo ============================================================
@echo Fractal Julia Test
@timeout 2 > nul
Compubench-Mobile-CLI.exe --gfx=glfw --test_id=cl_fractal_juliaset 
@pause
@echo ============================================================
@echo Gauss Buffered Test
@timeout 2 > nul
Compubench-Mobile-CLI.exe --gfx=glfw --test_id=cl_gauss_buff 
@pause
@echo ============================================================
@echo Gauss Image Test
@timeout 2 > nul
Compubench-Mobile-CLI.exe --gfx=glfw --test_id=cl_gauss_img 
@pause
@echo ============================================================
@echo Histogram Test
@timeout 2 > nul
Compubench-Mobile-CLI.exe --gfx=glfw --test_id=cl_histogram_buff 
@pause
@echo ============================================================
@echo Face detect Test
@timeout 2 > nul
Compubench-Mobile-CLI.exe --gfx=glfw --test_id=cl_histogram_img 
@pause
@echo ============================================================
@echo Face detect Test
@timeout 2 > nul
Compubench-Mobile-CLI.exe --gfx=glfw --test_id=cl_raytrace_ambocc 
@pause
@echo ============================================================
@echo Face detect Test
@timeout 2 > nul
Compubench-Mobile-CLI.exe --gfx=glfw --test_id=cl_raytrace_raycast 
@pause

:Quit
@echo ============================================
@echo Done with batch, no more operations from this point on.
@echo Script : %0% 
@echo version : %version%
@echo ============================================
exit /b