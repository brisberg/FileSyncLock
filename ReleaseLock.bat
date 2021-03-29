@ECHO off
SET "configfile=%~dp0config.txt"
IF Not Exist "%configfile%" (Goto :Error)

::Access config properties and read it as Key=Value
setlocal enabledelayedexpansion
for /f "tokens=1,* delims== " %%i in (%configfile%) do (
    SET "%%i=%%j"
)

ECHO Reading lockfile...
:: Read lockfile as Key=Value pairs
SET "lockfile=%gdrive_path%\%world_name%\lockfile.txt"
IF NOT Exist "%lockfile%" (Goto :Error)
for /f "usebackq tokens=1,2 delims== " %%i in ("%lockfile%") do (
    SET "lock_%%i=%%j"
)

IF NOT %lock_owner% == %user_email% (
    :: Lock is already owned by someone else
    ECHO Error: Current user '%lock_owner%' does not own the lock for '%world_name%'
    PAUSE
    EXIT
) ELSE IF %lock_owner% == %user_email% (
    :: Copy the server data to cloud backup
    ECHO Copying world data files from local disk to Cloud Backup...
    xcopy /y "%valheim_worlds_path%"\"%world_name%".* "%gdrive_path%"\"%world_name%"\

    @REM TODO: Rotate backups

    :: Release the lock
    ECHO. & ECHO Releasing lock for '%world_name%'... 
    ECHO owner=None > "%lockfile%"
    ECHO timestamp=2022 >> "%lockfile%"
    ECHO Lock released
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