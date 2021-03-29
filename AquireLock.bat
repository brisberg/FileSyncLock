@ECHO off
SET "configfile=%~dp0config.txt"
IF Not Exist "%configfile%" (Goto :Error)

::Access config properties and read it as Key=Value
setlocal enabledelayedexpansion
for /f "tokens=1,* delims== " %%i in (%configfile%) do SET "%%i=%%j"

ECHO Reading lockfile...
:: Read lockfile as Key=Value pairs
SET "lockfile=%gdrive_path%\%world_name%\lockfile.txt"
IF Not Exist "%lockfile%" (Goto :Error)
for /f "usebackq tokens=1,2 delims== " %%i in ("%lockfile%") do (
    SET "lock_%%i=%%j"
)

IF "%lock_owner%" == "None" (
    ECHO Lock for %world_name% is available...
    :: Lock is unowned and available
    ECHO Aquiring lock for '%world_name%' for user '%user_email%'
    ECHO owner=%user_email% > "%lockfile%"
    ECHO timestamp=2021 >> "%lockfile%"
    ECHO Lock aquired.

    ECHO. && ECHO Copying world data files from Cloud Backup to local disk...
    xcopy /y "%gdrive_path%"\"%world_name%"\"%world_name%".* "%valheim_worlds_path%"\

    ECHO ...Suceeded
    PAUSE
    EXIT
) ELSE IF NOT %lock_owner% == %user_email% (
    :: Lock is already owned by someone else
    ECHO Error: Lock for '%world_name%' already owned by another user "('%lock_owner%')"
    PAUSE
    EXIT
) ELSE IF %lock_owner% == %user_email% (
    :: User already owns the lock
    ECHO WARNING: Current user '%user_email%' already owns the lock for '%world_name%'
    PAUSE
    EXIT
) ELSE (
    ECHO Error: Lock for '%world_name%' is in an unknown state
    PAUSE
    EXIT
)

ECHO Finished
PAUSE
EXIT

::----------- Config Missing Error Handler
:Error
cls & Color 4C
ECHO  Error: Could not find "%configfile%", make sure to create a `config.txt` file in this directory.
PAUSE
EXIT