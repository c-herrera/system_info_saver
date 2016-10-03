@echo off
SetLocal EnableDelayedExpansion EnableExtensions

:: Obtiene el nombre de la carpeta de Flashfolders
for /f "delims=" %%a in ('chdir') do @set flash_dir=%%a

:: nombre del ifwi a usar
set ifwi=
:: Folder de los ifwi
set ifwi_folder=GELK

:: si no hay un parametro de ifwi valido ve a badsyntax
if "%1"=="" goto badsyntax
:: Si hay un parametro de ifwi, asignalo a ifwi_ver
set ifwi_ver=%1
:: completa el nombre de la ruta del ifwi como IFWI\GELK\2016_19_4_00
::set ifwi=IFWI\%ifwi_folder%\%ifwi_ver%
set ifwi=IFWI\%ifwi_ver%

:: Si no hay ifwi definido tomara el nombre de ifwi+_Release
if not exist %ifwi% set ifwi=%ifwi%_Release
:: si no existe el ifwi por completo ve a noifwi
if not exist %ifwi% goto noifwi
:: pon el prefijo del archivo bios a GLKKRVP_X64_R_
set ifwi_prefix=GLKKRVP_X64_R_

:: Esta parte es solo para APL RVP son los steppings y la busqueda
:: de la configuracion del stitch configuracion
:: si se asigna uno de los steppings A0, B0 o B1

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


:: Pone la variable del folder de stitch
set stitch_config_folder=Stitch

:: Da el valor del archivo de stitch_config y pasa toda la ruta completa
:: Carpeta de GLK\IFWI\FECHA_DEL_IFWI\Stitch\Stitch_Config.txt
:: si no lo encuentra debe ir a nostitchconfig
set stitch_config=%ifwi%\Stitch\%stitch_config_folder%\Stitch_Config.txt
if not exist %stitch_config% goto nostitchconfig

:: Parse the Stitch_Config File
set line=0
set endline=0

:: busca y procesa el archivo Stitch_Config
for /f "delims=:" %%i in ('findstr /inc:"%strfind%" "%stitch_config%"') do (
	set /a line=%%i
	set /a endline=!line!+8
)

::if "%4"=="B0" set /a line-=1 & set /a endline-=1
::if "%4"=="B1" set /a line-=2 & set /a endline-=2

:: Busca los componentes CSE y GOP dentro de Stitch_Config
set /a counter=1
for /f "delims== tokens=1,2" %%i in (%stitch_config%) do (
	if !counter! GEQ %line% if !counter! LSS %endline% if "%%i"=="CSE" set stitch_config_cse_version=%%j
	if !counter! GEQ %line% if !counter! LSS %endline% if "%%i"=="GOP" set stitch_config_gop_version=%%j
	set /a counter=counter+1
)

:: asigna la ruta donde esta el GOP y CSE en el stitch folder
:: algo como -> FLASHGLK\IFWI\Stitch\Stitch\CSE\4.0.0.1129\
set gop_folder=%ifwi%\Stitch\%stitch_config_folder%\GOP\%stitch_config_gop_version%\%ifwi_folder%
set cse_folder=%ifwi%\Stitch\%stitch_config_folder%\CSE\%stitch_config_cse_version%\%ifwi_folder%\FIT\xml\

@echo Note: This script must be run under Windows DOS Prompt.

:: Copia los archivos de CSE  y lo renombra y borra el anterior
if exist %cse_folder%\bxt_emmc_8mb_RVP1.xml.bkp (
	copy %cse_folder%\bxt_emmc_8mb_RVP1.xml.bkp %cse_folder%\bxt_emmc_8mb_RVP1.xml
	del %cse_folder%\bxt_emmc_8mb_RVP1.xml.bkp
)
if exist %cse_folder%\bxt_spi_8mb_RVP1.xml.bkp (
	copy %cse_folder%\bxt_spi_8mb_RVP1.xml.bkp %cse_folder%\bxt_spi_8mb_RVP1.xml
	del %cse_folder%\bxt_spi_8mb_RVP1.xml.bkp
)

:: obtiene la ruta del BIOS, y se la asigna a sbios
:: se encuentra en la ruta principal donde empieza la carpeta
:: siendo GLK\GLKKRVP_X64_R_.zip
set sbios=
for /f %%x in ('dir /b %ifwi%\%ifwi_prefix%*.zip') do set bios_name=%%x
set sbios=%ifwi%\%bios_name%


:: Busca y asigna el GOP
set gop=

:: si no se definio el GOP
if "%2"=="" goto badsyntax
:: de lo contrario asignalo de la linea de comandos
set gop_ver=%2

:: asigna la ruta donde esta el efi  release
set gop=EFI\%gop_ver%\NetbookGopDriver\RELEASE_VS2008x86\X64\IntelGopDriver.efi

:: si no hay tal archivo, asigna el estandar
if not exist %gop% set gop=EFI\%gop_ver%\IntelGopDriver\RELEASE_VS2008x86\X64\IntelGopDriver.efi

:: si no hay absolutamene nada ve a nogop
if not exist %gop% goto nogop

::  asigna el gop de la carpeta EFI/NumerodeGOP/Netbook/vbt.bsf
set gopbsf=EFI\%gop_ver%\VBT\Netbook\vbt.bsf

:: asigna el respaldo de el VBT
set bsfbkp=%gop_folder%\VBT\vbt.bsf

:: busca en el archivo asignado a %gop% el nombre de esta a is_file
for /f "delims=" %%a in ('attrib %gop%') do @set is_file=%%a

:: si no encontro nada en sus atributos, brinca a notfile_gop
if not "%is_file:~0,1%"=="A" goto notfile_gop

:: checa si se ha asignado un nombre de display entre eDP, MIPI, MIPI JDI etc
:: si no fue asignado, brinca a badsyntex
if /I not "%3"=="A" if /I not "%3"=="E" if /I not "%3"=="J" if /I not "%3"=="S" goto badsyntax

:: de lo contrario asigna el tercer parametro a display_type
set display_type=%3


::if "%4"=="B0" set step=/B0& set step2=_B0
:: "%4"=="B1" set step=/B0& set step2=_B0


:: crea un argumento temporal para buscar archivos en la carpeta de CSE
set argT=0
for %%x in (%*) do set /a argT+=1
:: si argT es mayor a 4 y el argumento 5 es SG de Switchable Graphics
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

:: da el valor de vbt a el argumento intercambiado de el ciclo anterior
:: se lo pasa a vbtn
set vbt=%~f5
set vbtn=%vbt%


:: Todo lo que sigue es para los displays eDP, MIPI
:: no son requeridos en GLK

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

:: si no hay vbt brinca a novbt
if not exist %vbt% goto novbt

:: busca en los atributos de vbt por el valor de archive
:: si no lo encuentra, va a notfile_vbt

for /f "delims=" %%a in ('attrib %vbt%') do @set is_file=%%a
if not "%is_file:~0,1%"=="A" goto notfile_vbt


:: copia el sbios asignado de la plataforma y lo busca en el folder
:: de stitch

copy /Y %sbios% %ifwi%\Stitch\%stitch_config_folder%\
:: Backup original IntelGopDriver.efi
copy %gop_folder%\Driver\X64\IntelGopDriver.efi %ifwi%\Stitch\original_gop.efi.bkp
copy /Y %gop% %gop_folder%\Driver\X64\IntelGopDriver.efi


:: asigna el nombre y ruta del ifwi a la encontrada anteriormente
:: si no hay, lo cambia al release.

set ifwi=IFWI\%ifwi_folder%\%ifwi_ver%
if not exist %ifwi% set ifwi=%ifwi%_Release
:: Backup original Vbt
:: respalda todos los archivos de gop y vbt necesarios
if exist %gopbsf% copy /Y %gopbsf% %bsfbkp%
if exist %vbtn% copy /Y %vbtn% %backupvbt%
if exist %vbtn% copy /Y %vbt% %gop_folder%\VBT\Vbt.bin
if exist %vbtn% copy /Y %vbt% %vbtn%
rem if exist %vbtn% (for /f %%x in ('dir /b %gop_folder%\VBT\*.bin') do copy /Y %vbt% %gop_folder%\VBT\%%x)
:: tambien respalda el folder del display jdi
if exist %nojdi% copy  /Y %nojdi% %ifwi%\Stitch\original_Vbt.bin.bkp
if not exist %vbtn% copy /Y %vbt% %nojdi%


timeout /t 2 /nobreak>nul

:: cambia al directorio donde esta el flash dir que debe se donde se encuentra todo
cd %flash_dir%

:: quita el atributo de solo lectura a todo el folder de stitch
@echo -----------------------------------
@echo   PUTTING OFF ONLY-READ ATTRIBUTE
@echo -----------------------------------
for /R %ifwi%\Stitch\ %%G IN (*.*) do attrib -r "%%G"
@echo -----------------------------------
@echo   READ-ONLY ATTRIBUTE ELIMINATED
@echo -----------------------------------

:: cambia al directorio de stitch
cd .\%ifwi%\Stitch\%stitch_config_folder%
:: si la configuracion del stepping es B0 (production), usa  el Stitch_Config del
:: numero de bios de produccion con el IFWIStitch.bat
:: si no, va al folder del stepping correcto de cpu de preproduccion
if %strfind%==[APLK_B0_PROD] (
	call IFWIStitch.bat /PROD %bios_name% /C %flash_dir%\%ifwi%\Stitch\%stitch_config_folder%\Stitch_Config.txt
) ELSE (
	call IFWIStitch.bat %step% %bios_name% /C %flash_dir%\%ifwi%\Stitch\%stitch_config_folder%\Stitch_Config.txt
)
:: si encontro algun error, deja todo
if errorlevel 1 goto abort

:: cambia otra vez al flash flash_dir
cd %flash_dir%
:: copia todo los archivos de la carpeta del ifwi que sean *.bin o *.zip
for /f %%x in ('dir /b %ifwi%\Stitch\%stitch_config_folder%\%ifwi_folder%%step2%_IFWI_X64_R_*SPI*.bin') do copy %ifwi%\Stitch\%stitch_config_folder%\%%x .\efi-%ifwi_folder%_APL_%4-X64-%ifwi_ver%-%gop_ver%-SPI-%paneltype%%SG%.bin
for /f %%x in ('dir /b %ifwi%\Stitch\%stitch_config_folder%\*.bin') do del %ifwi%\Stitch\%stitch_config_folder%\%%x
for /f %%x in ('dir /b %ifwi%\Stitch\%stitch_config_folder%\*.zip') do del %ifwi%\Stitch\%stitch_config_folder%\%%x
echo.
echo Success.

:: IFWI Creado

echo Merged EFI IFWI: efi-%ifwi_folder%_APL_%4-X64-%ifwi_ver%-%gop_ver%-SPI-%paneltype%%SG%.bin
goto end

:badsyntax
@echo Bad Syntaxis, needs to be acording as :
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
