@echo off
@cls

title Disabling Driver Integrity Check

@echo -----------------------------------------------------
@echo Trying to set testsigning %1
@echo Remember to disable this when testing is done
if "%1" == "" goto badsyntax

if "%1" == "on" (
@echo -----------------------------------------------------
@echo Setting DDISABLE_INTEGRITY_CHECKS on
bcdedit /set testsigning on
@echo.
bcdedit.exe /set loadoptions DDISABLE_INTEGRITY_CHECKS
@echo.
bcdedit.exe /set TESTSIGNING ON
goto quit
)

if "%1" == "off" (
@echo -----------------------------------------------------
@echo Setting DDISABLE_INTEGRITY_CHECKS off
bcdedit /set testsigning off
@echo.
bcdedit.exe -set TESTSIGNING OFF
@echo.
goto quit
)

:badsyntax
@cls
@echo Incorrect sintax. To run this batch your input must be as follows :
@echo.
@echo.
@echo.
@echo. %0 on - off
@echo. example :
@echo. %0 on
goto quit

:quit
@echo Done.



