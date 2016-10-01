@echo off
SetLocal EnableDelayedExpansion EnableExtensions
for /f "delims=" %%a in ('chdir') do @set flash_dir=%%a

set ifwi=
set ifwi_folder=GELK

if "%1"=="" goto badsyntax
set ifwi_ver=%1
::set ifwi=IFWI\%ifwi_folder%\%ifwi_ver%
set ifwi=IFWI\%ifwi_ver%
if not exist %ifwi% set ifwi=%ifwi%_Release
if not exist %ifwi% goto noifwi
set ifwi_prefix=GLKKRVP_X64_R_
::if /I not "%4"=="A0" if /I not "%4"=="B0" if /I not "%4"=="B1" goto badsyntax
::if "%4"=="A0" (
::	set stitch_config_folder=Stitch
::	set strfind=[APLK]
::)
::if "%4"=="B0" (
::	set stitch_config_folder=Stitch
::	set strfind=[APLK_B0]
::)
::if "%4"=="B1" (
::	if exist %ifwi%\Stitch\Stitch_Prod (
::		set stitch_config_folder=Stitch_Prod
::		set strfind=[APLK_B0]
::	) else if not exist %ifwi%\Stitch\Stitch_Prod (
::		set stitch_config_folder=Stitch
::		set strfind=[APLK_B0_PROD]
::	)
::)

set stitch_config_folder=Stitch

set stitch_config=%ifwi%\Stitch\%stitch_config_folder%\Stitch_Config.txt
if not exist %stitch_config% goto nostitchconfig

:: Parse the Stitch_Config File
set line=0
set endline=0

for /f "delims=:" %%i in ('findstr /inc:"%strfind%" "%stitch_config%"') do (
	set /a line=%%i
	set /a endline=!line!+8
)

::if "%4"=="B0" set /a line-=1 & set /a endline-=1
::if "%4"=="B1" set /a line-=2 & set /a endline-=2

set /a counter=1
for /f "delims== tokens=1,2" %%i in (%stitch_config%) do (
	if !counter! GEQ %line% if !counter! LSS %endline% if "%%i"=="CSE" set stitch_config_cse_version=%%j
	if !counter! GEQ %line% if !counter! LSS %endline% if "%%i"=="GOP" set stitch_config_gop_version=%%j
	set /a counter=counter+1
)

set gop_folder=%ifwi%\Stitch\%stitch_config_folder%\GOP\%stitch_config_gop_version%\%ifwi_folder%
set cse_folder=%ifwi%\Stitch\%stitch_config_folder%\CSE\%stitch_config_cse_version%\%ifwi_folder%\FIT\xml\

@echo Note: This script must be run under Windows DOS Prompt.

if exist %cse_folder%\bxt_emmc_8mb_RVP1.xml.bkp (
	copy %cse_folder%\bxt_emmc_8mb_RVP1.xml.bkp %cse_folder%\bxt_emmc_8mb_RVP1.xml
	del %cse_folder%\bxt_emmc_8mb_RVP1.xml.bkp
)
if exist %cse_folder%\bxt_spi_8mb_RVP1.xml.bkp (
	copy %cse_folder%\bxt_spi_8mb_RVP1.xml.bkp %cse_folder%\bxt_spi_8mb_RVP1.xml
	del %cse_folder%\bxt_spi_8mb_RVP1.xml.bkp
)

set sbios=
for /f %%x in ('dir /b %ifwi%\%ifwi_prefix%*.zip') do set bios_name=%%x
set sbios=%ifwi%\%bios_name%

set gop=
if "%2"=="" goto badsyntax
set gop_ver=%2
set gop=EFI\%gop_ver%\NetbookGopDriver\RELEASE_VS2008x86\X64\IntelGopDriver.efi
if not exist %gop% set gop=EFI\%gop_ver%\IntelGopDriver\RELEASE_VS2008x86\X64\IntelGopDriver.efi
if not exist %gop% goto nogop
set gopbsf=EFI\%gop_ver%\VBT\Netbook\vbt.bsf
set bsfbkp=%gop_folder%\VBT\vbt.bsf
for /f "delims=" %%a in ('attrib %gop%') do @set is_file=%%a
if not "%is_file:~0,1%"=="A" goto notfile_gop

if /I not "%3"=="A" if /I not "%3"=="E" if /I not "%3"=="J" if /I not "%3"=="S" goto badsyntax
set display_type=%3

::if "%4"=="B0" set step=/B0& set step2=_B0
:: "%4"=="B1" set step=/B0& set step2=_B0

set argT=0
for %%x in (%*) do set /a argT+=1
if %argT% GTR 4 (
	if "%5"=="SG" (
		copy %cse_folder%\bxt_emmc_8mb_RVP1.xml %cse_folder%\bxt_emmc_8mb_RVP1.xml.bkp
		copy %cse_folder%\bxt_emmc_8mb_RVP1_Hybrid.xml %cse_folder%\bxt_emmc_8mb_RVP1.xml
		copy %cse_folder%\bxt_spi_8mb_RVP1.xml %cse_folder%\bxt_spi_8mb_RVP1.xml.bkp
		copy %cse_folder%\bxt_spi_8mb_RVP1_Hybrid.xml %cse_folder%\bxt_spi_8mb_RVP1.xml
		set SG=_Hybrid
		SHIFT /5
	)
)

set vbt=%~f5
set vbtn=%vbt%

::
if /I "%display_type%"=="A" (
	if "%5"=="" set vbt=%flash_dir%\EFI\%gop_ver%\VBT\Netbook\Vbt_bxt_p_AuoMipi.bin
	set vbtn=%gop_folder%\VBT\Vbt_bxt_p_AuoMipi.bin
	set backupvbt=%ifwi%\Stitch\original_vbt_AuoMipi.bin.bkp
	set paneltype=AUO_Landscape
) else if /I "%display_type%"=="E" (
	if "%5"=="" set vbt=%flash_dir%\EFI\%gop_ver%\VBT\Netbook\Vbt_bxt_p_eDp.bin
	set vbtn=%gop_folder%\VBT\Vbt_bxt_p_eDp.bin
	set backupvbt=%ifwi%\Stitch\original_vbt_eDP.bin.bkp
	set paneltype=eDP
) else if /I "%display_type%"=="J" (
	if "%5"=="" set vbt=%flash_dir%\EFI\%gop_ver%\VBT\Netbook\Vbt_bxt_p_JdiMipi.bin
	set vbtn=%gop_folder%\VBT\Vbt_bxt_p_JdiMipi.bin
	set backupvbt=%ifwi%\Stitch\original_vbt_JDI.bin.bkp
	set paneltype=JDI_Portrait
	set nojdi=%gop_folder%\VBT\Vbt.bin
) else if /I "%display_type%"=="S" (
	if "%5"=="" set vbt=%flash_dir%\EFI\%gop_ver%\VBT\Netbook\Vbt_bxt_p_SharpDualLinkMipi.bin
	set vbtn=%gop_folder%\VBT\Vbt_bxt_p_SharpDualLinkMipi.bin
	set backupvbt=%ifwi%\Stitch\original_vbt_SharpDualLinkMipi.bin.bkp
	set paneltype=Sharp_Dual_Link
)


if not exist %vbt% goto novbt
for /f "delims=" %%a in ('attrib %vbt%') do @set is_file=%%a
if not "%is_file:~0,1%"=="A" goto notfile_vbt

copy /Y %sbios% %ifwi%\Stitch\%stitch_config_folder%\
:: Backup original IntelGopDriver.efi
copy %gop_folder%\Driver\X64\IntelGopDriver.efi %ifwi%\Stitch\original_gop.efi.bkp
copy /Y %gop% %gop_folder%\Driver\X64\IntelGopDriver.efi

set ifwi=IFWI\%ifwi_folder%\%ifwi_ver%
if not exist %ifwi% set ifwi=%ifwi%_Release
:: Backup original Vbt
if exist %gopbsf% copy /Y %gopbsf% %bsfbkp%
if exist %vbtn% copy /Y %vbtn% %backupvbt% 
if exist %vbtn% copy /Y %vbt% %gop_folder%\VBT\Vbt.bin
if exist %vbtn% copy /Y %vbt% %vbtn%
rem if exist %vbtn% (for /f %%x in ('dir /b %gop_folder%\VBT\*.bin') do copy /Y %vbt% %gop_folder%\VBT\%%x)
if exist %nojdi% copy  /Y %nojdi% %ifwi%\Stitch\original_Vbt.bin.bkp
if not exist %vbtn% copy /Y %vbt% %nojdi%

timeout /t 2 /nobreak>nul

cd %flash_dir%
@echo -----------------------------------
@echo   PUTTING OFF ONLY-READ ATTRIBUTE
@echo -----------------------------------
for /R %ifwi%\Stitch\ %%G IN (*.*) do attrib -r "%%G"
@echo -----------------------------------
@echo   READ-ONLY ATTRIBUTE ELIMINATED
@echo -----------------------------------
cd .\%ifwi%\Stitch\%stitch_config_folder%
if %strfind%==[APLK_B0_PROD] (
	call IFWIStitch.bat /PROD %bios_name% /C %flash_dir%\%ifwi%\Stitch\%stitch_config_folder%\Stitch_Config.txt
) ELSE (
	call IFWIStitch.bat %step% %bios_name% /C %flash_dir%\%ifwi%\Stitch\%stitch_config_folder%\Stitch_Config.txt
)
if errorlevel 1 goto abort
cd %flash_dir%
for /f %%x in ('dir /b %ifwi%\Stitch\%stitch_config_folder%\%ifwi_folder%%step2%_IFWI_X64_R_*SPI*.bin') do copy %ifwi%\Stitch\%stitch_config_folder%\%%x .\efi-%ifwi_folder%_APL_%4-X64-%ifwi_ver%-%gop_ver%-SPI-%paneltype%%SG%.bin
for /f %%x in ('dir /b %ifwi%\Stitch\%stitch_config_folder%\*.bin') do del %ifwi%\Stitch\%stitch_config_folder%\%%x
for /f %%x in ('dir /b %ifwi%\Stitch\%stitch_config_folder%\*.zip') do del %ifwi%\Stitch\%stitch_config_folder%\%%x
echo.
echo Success. 
echo Merged EFI IFWI: efi-%ifwi_folder%_APL_%4-X64-%ifwi_ver%-%gop_ver%-SPI-%paneltype%%SG%.bin
goto end

:badsyntax
@echo Bad Syntaxis, needs be acording the next:
@echo Syntax:
@echo 	%0 IFWI_ver GOP_ver Display_Type Stepping [SG] [custom_VBT_file_or_filepath]
@echo.
@echo Where:
@echo 			Display_Type can be E (eDP), A (Auo Mipi Landscape), S (MIPI Sharp Dual Link) or J (JDI Portrait) {MANDATORY}
@echo.
@echo				Stepping can be A0, B0 or B1 -- {MANDATORY}
@echo.
@echo				[SG] -- Switchable Graphics -- OPTIONAL
@echo.
@echo				[custom_VBT_file_or_filepath] -- VBT Custom -- OPTIONAL
@echo.
@echo Examples:
@echo 	%0 2016_19_4_00 10.0.1029 E B0 SG
@echo 	%0 2016_19_4_00 10.0.1029 A A0
@echo 	%0 2016_19_4_00 10.0.1029 S B0 SG
@echo 	%0 2016_19_4_00 10.0.1029 J B1
@echo 	%0 2016_19_4_00 10.0.1029 E B0 SG My_eDP_VBT.bin
@echo 	%0 2016_19_4_00 10.0.1029 A A0 My_AUO_MipiVBT.bin
@echo 	%0 2016_19_4_00 10.0.1029 S B0 SG My_Sharp_MpiVBT.bin
@echo 	%0 2016_19_4_00 10.0.1029 J B1 My_JDI_MipiVBT.bin
goto end

:noifwi
@echo File not found: %ifwi%
goto end

:nostitchconfig
@echo File not found: %stitch_config%
goto end

:novbt
@echo File not found: %vbt%
goto end

:nogop
@echo File not found: %gop%
goto end

:notfile_vbt
@echo Not a file: %vbt%
goto end

:notfile_gop
@echo Not a file: %gop%
goto end

:abort
@echo FATAL ERROR

:end
:: Restore original GOP files
cd %flash_dir%
if exist %ifwi%\Stitch\original_gop.efi.bkp move /Y %ifwi%\Stitch\original_gop.efi.bkp %gop_folder%\Driver\X64\IntelGopDriver.efi
if exist %ifwi%\Stitch\original_Vbt_bxt_t_TianmaMipi.bin.bkp move /Y %ifwi%\Stitch\original_Vbt_bxt_t_TianmaMipi.bin.bkp %gop_folder%\VBT\Vbt_bxt_t_TianmaMipi.bin
if exist %backupvbt% move /Y %backupvbt% %vbtn%
rem if exist %ifwi%\Stitch\original_Vbt.bin.bkp move /Y %ifwi%\Stitch\original_Vbt.bin.bkp %nojdi%