@echo off
@cls

title Disabling Driver Integrity Check

@echo -----------------------------------------------------
@echo Setting testsigning on
@echo Remember to disable this when testing is done
if %1 == "" goto noarguments

if "%1" == "on" (
bcdedit /set testsigning on
@echo Setting DDISABLE_INTEGRITY_CHECKS on
bcdedit.exe -set loadoptions DDISABLE_INTEGRITY_CHECKS
bcdedit.exe -set TESTSIGNING ON
)

if "%1" == "off" (
bcdedit /set testsigning off
@echo Setting DDISABLE_INTEGRITY_CHECKS off
bcdedit.exe -set TESTSIGNING OFF
)

:noarguments
@echo To run this command properly  you must use the next sintax
@echo disable_driver_sign on

:quit
@echo Done.

