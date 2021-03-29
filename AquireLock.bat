@ECHO off
SET "configfile=config.txt"
IF Not Exist "%configfile%" (Goto :Error)

::Access config properties and read it as Key=Value
setlocal enabledelayedexpansion
for /f "tokens=1,* delims== " %%i in (%configfile%) do SET "%%i=%%j"

ECHO %user_email%
ECHO %world_name%
ECHO %gdrive_path%
ECHO %valheim_worlds_path%

ECHO Copying world data files to Cloud Backup...
xcopy /y "%valheim_worlds_path%"\"%world_name%".* "%gdrive_path%"\"%world_name%"\

PAUSE
EXIT

::----------- Config Missing Error Handler
:Error
cls & Color 4C
ECHO  Error: Could not find "%configfile%", make sure to create a `config.txt` file in this directory.
PAUSE
EXIT