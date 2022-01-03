@echo off
color 0a
title Folder Locker
set "version=0.9.7"
:top
if NOT EXIST "%appdata%/locker/currentversion" goto createcurrentversion
set "previousversion="
FOR /F %%I IN (`type "%appdata%/locker/currentversion"`) DO @SET "previousversion=%%I"
if NOT EXIST "%appdata%/locker/password/pass.encode" goto setpassword
if EXIST "Control Panel.{21EC2020-3AEA-1069-A2DD-08002B30309D}" goto UNLOCK
if NOT EXIST Private goto MDPrivate
if NOT "%previousversion%"=="%version%" goto postupdate
:CONFIRM
cls
color 0a
echo What do you went to do with the private folder.
echo (1)Lock the folder.
echo (2)Change the password.
echo (3)Reset the folder locker.
if %log%== 1 set lognow=off
if not %log%== 1 set lognow=on
echo (4)Turn %lognow% loging.
echo (5)Update
echo (6)Exit
set/p "cho=>"
if %cho%==1 goto LOCK
if %cho%==2 goto set1password
if %cho%==3 goto resetcon
if %cho%==4 goto log
if %cho%==5 goto updatelocker
if %cho%==6 goto End
echo Invalid choice.
goto CONFIRM
:LOCK
if %log%== 1 echo %date% %time%>> "private/logs/folder locker log.log" && echo Private folder locked>> "private/logs/folder locker log.log"
ren Private "Control Panel.{21EC2020-3AEA-1069-A2DD-08002B30309D}"
attrib +h +s "Control Panel.{21EC2020-3AEA-1069-A2DD-08002B30309D}"
cls
echo Folder locked
pause
goto End
:UNLOCK
echo Enter password to Unlock Your Secure Folder
set/p "pass=>"
cls
echo Authencating
FOR /F "tokens=* USEBACKQ" %%F IN (`powershell "[convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes(\"%pass%\"))"`) DO (
SET word=%%F
)
FOR /F "tokens=* USEBACKQ" %%F IN (`type "%appdata%/locker/password/pass.encode"`) DO (
SET hash=%%F
)
if NOT "%word%"=="%hash%" goto FAIL
attrib -h -s "Control Panel.{21EC2020-3AEA-1069-A2DD-08002B30309D}"
ren "Control Panel.{21EC2020-3AEA-1069-A2DD-08002B30309D}" Private
cls
if %log%== 1 echo %date% %time%>> "private/logs/folder locker log.log" && echo Private folder unlocked>> "private/logs/folder locker log.log"
echo Authencating completed successfuly
echo Folder Unlocked
pause
goto End
:FAIL
cls
if %log%== 1 echo %date% %time%>> "Control Panel.{21EC2020-3AEA-1069-A2DD-08002B30309D}/logs/folder locker log.log" && echo User entered invalid password>> "Control Panel.{21EC2020-3AEA-1069-A2DD-08002B30309D}/logs/folder locker log.log"
echo Authencating failed
echo Invalid password
pause
goto end
:MDPrivate
md Private
echo %newhash%>> "Private/pass.encode"
attrib +h +s "Private/pass.encode"
echo Private created successfully
pause
goto End
:setpassword
md "%appdata%/locker/password/"
if EXIST "Control Panel.{21EC2020-3AEA-1069-A2DD-08002B30309D}" goto tampered
echo Set a password.
set/p "setpass=>" 
FOR /F "tokens=* USEBACKQ" %%F IN (`powershell "[convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes(\"%setpass%\"))"`) DO (
SET newhash=%%F
)
echo %newhash%>> "%appdata%/locker/password/pass.encode"
attrib +h +s "%appdata%/locker/password/pass.encode"
setx log 0
goto top
:tampered
if %log%== 1 echo %date% %time%>> "Control Panel.{21EC2020-3AEA-1069-A2DD-08002B30309D}/logs/folder locker log.log" && echo Password tampered>> "Control Panel.{21EC2020-3AEA-1069-A2DD-08002B30309D}/logs/folder locker log.log"
echo The folder locker has detected tampering with the password.
echo Restoring password.
xcopy "Control Panel.{21EC2020-3AEA-1069-A2DD-08002B30309D}\pass.encode" "%appdata%\locker\password\" /q /h /y
pause
goto End
:set1password
echo Enter old password
set/p "pass=>"
cls
echo Authencating
FOR /F "tokens=* USEBACKQ" %%F IN (`powershell "[convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes(\"%pass%\"))"`) DO (
SET word=%%F
)
FOR /F "tokens=* USEBACKQ" %%F IN (`type "%appdata%/locker/password/pass.encode"`) DO (
SET hash=%%F
)
if NOT "%word%"=="%hash%" goto FAIL
attrib -h -s "Control Panel.{21EC2020-3AEA-1069-A2DD-08002B30309D}"
ren "Control Panel.{21EC2020-3AEA-1069-A2DD-08002B30309D}" Private
cls
echo Authencating completed successfuly
echo Enter new password.
set/p "setpass=>"
echo Confirm new password.
set/p "setconpass=>"
if not "%newpass%"=="%newconpass%" echo Password does not match && pause && exit
FOR /F "tokens=* USEBACKQ" %%F IN (`powershell "[convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes(\"%setpass%\"))"`) DO (
SET newhash=%%F
)
del /F /Q /A "%appdata%\locker\password\pass.encode"
del /F /Q /A "Private\pass.encode"
echo %newhash%>> "%appdata%/locker/password/pass.encode"
attrib +h +s "%appdata%/locker/password/pass.encode"
echo %newhash%>> "Private/pass.encode"
attrib +h +s "Private/pass.encode"
if %log%== 1 echo %date% %time%>> "private/logs/folder locker log.log" && echo Password changed>> "private/logs/folder locker log.log"
goto top
:log
cls
if %log%== 0 setx log 1
if not %log%== 0 setx log 0
echo Setting log complete.
md "Private/logs"
echo %date% %time%>> "private/logs/folder locker log.log"
echo Logging turned %lognow%>> "private/logs/folder locker log.log"
pause
goto End
:updatelocker
cls
echo Checking for Updates
FOR /F "tokens=* USEBACKQ" %%F IN (`netsh interface show interface ^| Findstr /c:"Connected"^>nul ^&^& Echo Online ^|^| Echo Offline`) DO (
SET internet=%%F
)
if "%internet%"== "Offline" cls & echo No Internet Connection is Available & echo An Internet Connection is Needed to Update the Folder Locker. & pause & goto CONFIRM
powershell "(New-Object System.Net.WebClient).DownloadFile(\"https://raw.githubusercontent.com/annpocoyo/Folder-Locker/main/version.txt\", $env:temp + \"\version.txt\")"
FOR /F "tokens=* USEBACKQ" %%F IN (`type "%temp%\version.txt"`) DO (
SET newversion=%%F
)
del /f "%temp%\version.txt"
if not "%newversion%" gtr "%version%" goto uptodate
cls
echo Updating to Version: %newversion%
echo @echo off>> %temp%\update.bat
echo color 0a>> %temp%\update.bat
echo echo Updating to Version: %newversion%>> %temp%\update.bat
echo move /Y "%%temp%%\Folder Locker.bat"  "%~f0">> %temp%\update.bat
echo start "" "%~f0">> %temp%\update.bat
echo del /F "%%~f0" ^& exit>> %temp%\update.bat
powershell "(New-Object System.Net.WebClient).DownloadFile(\"https://raw.githubusercontent.com/annpocoyo/Folder-Locker/main/Folder%%20Locker.bat\", $env:temp + \"\Folder Locker.bat\")"
(
start "" "%temp%\update.bat"
exit
)
:uptodate
cls
echo Up to Date
pause
goto CONFIRM
:createcurrentversion
CALL :setcurrentversion
goto top
:setcurrentversion
echo %version%> %appdata%/locker/currentversion
EXIT /B 0
:postupdate
echo Updating to Version: %version%
CALL :setcurrentversion
echo Update Installed Successfully
pause
goto top
:resetcon
cls
color 0c
echo Are you sure you went to reset the folder locker.
echo Your files in the private folder will be backed up to private_old and than be
echo deleted.
echo Type in 1234a to start reseting
set/p "conryanryan=>"
if not %conryanryan%== 1234a goto CONFIRM
echo Enter password to confirm reset
set/p "pass=>"
cls
echo Authencating
FOR /F "tokens=* USEBACKQ" %%F IN (`powershell "[convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes(\"%pass%\"))"`) DO (
SET word=%%F
)
FOR /F "tokens=* USEBACKQ" %%F IN (`type "%appdata%/locker/password/pass.encode"`) DO (
SET hash=%%F
)
if NOT "%word%"=="%hash%" goto FAIL
attrib -h -s "Control Panel.{21EC2020-3AEA-1069-A2DD-08002B30309D}"
ren "Control Panel.{21EC2020-3AEA-1069-A2DD-08002B30309D}" Private
cls
echo Authencating completed successfuly
echo Reseting folder locker.
if %log%== 1 echo %date% %time%>> "private/logs/folder locker log.log" && echo Folder locker reseted>> "private/logs/folder locker log.log"
echo.
echo Backing up private folder
xcopy Private Private_old\ /Y /E
echo.
echo Deleting private folder
rmdir /s /q "private"
echo.
echo Deleting Configuration
rmdir /s /q "%appdata%\locker"
echo.
echo Done
echo.
pause
goto End
:End
