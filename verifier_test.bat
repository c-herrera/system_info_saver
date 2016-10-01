

@ECHO OFF
SETLOCAL ENABLEEXTENSIONS

:: script global variables
SET me=%~n0
REM create a log file named [script].YYYYMMDDHHMMSS.txt
SET log=Log-%me%.%DATE:~10,4%_%DATE:~4,2%_%DATE:~7,2%%TIME:~0,2%_%TIME:~3,2%_%TIME:~6,2%.txt

:menu1
@cls
@echo Driver verifier options :
@echo.
@echo   1. Verifier Help (saves a copy for better reading)
@echo   2. Verifier set Standard options
@echo   3. Verifier enable all
@echo   4. Verifier get basic info
@echo   5. Verifier get more info
@echo   6. Verifier reset
@echo   7. Verifier volatile
@echo   8. Verifier logging
@echo   9. Verifier live dump
@echo  10. Verifier one check
@echo  11. Quit
set /p input=Select an option- 


if '%input%' == '1' goto verifier_help
if '%input%' == '2' goto verifier_standard
if '%input%' == '3' goto verifier_all
if '%input%' == '4' goto verifier_query
if '%input%' == '5' goto verifier_querysettings
if '%input%' == '6' goto verifier_reset
if '%input%' == '7' goto verifier_volatile
if '%input%' == '8' goto verifier_logging
if '%input%' == '9' goto verifier_livedump
if '%input%' == '10' goto verifier_onecheck

if '%input%' == '11' goto quit


goto menu1

:verifier_help
@cls
@echo Displays verifier help
@echo A copy will be saved on your disk
verifier /help > verifier_help.txt
timeout 2
goto menu1


:verifier_standard
@cls
@echo Specifies standard Driver Verifier flags. This is equivalent to '/flags 0x209BB'.
verifier /standard
timeout 1
goto menu1


:verifier_all
@cls
@echo Specifies that all installed drivers will be verified after the next boot.
verifier /all
timeout 1
goto menu1


:verifier_query
@cls
@echo Display runtime Driver Verifier statistics and settings.
verifier /query >>  %log%
timeout 2
goto menu1

:verifier_querysettings
@cls
@echo Displays a summary of the options and drivers that are currently
@echo enabled, or options and drivers that will be verified after the
@echo next boot. The display does not include drivers and options added
@echo using /volatile.
verifier /querysettings >> %log%
timeout 2
goto menu1

:verifier_reset
@cls
@echo Clears Driver Verifier flags and driver settings. This option requires
@echo system reboot to take effect.
verifier /reset
timeout 3
goto menu1

:verifier_volatile
@cls
@echo Changes Driver Verifier settings without rebooting the computer.
@echo Volatile settings take effect immediately and are in effect until the
@echo next system reboot.
verifier /volatile
timeout 2
goto menu1

:verifier_logging
@cls
@echo Enables logging for violated rules detected by the selected verifier
@echo extensions.
verifier /logging
timeout 2
goto menu1

:verifier_livedump
@cls
@echo Enables live memory dump collection for violated rules detected by
@echo the selected verifier extensions.
verifier /livedump
timeout 2
goto menu1

:verifier_onecheck
@cls
@echo Enables reporting of violated rules only for the first instances
@echo detected by the selected verifier extensions.
verifier /onecheck
goto menu1

:quit
@cls
@echo Batch ended
