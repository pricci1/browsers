@echo off

echo Starting Installation
REM Delayed Expansion is usually disabled by default, but
REM we are explicit about it here not to make that assumption
setlocal DisableDelayedExpansion

REM Sets ARCH to ARM64 or AMD64
for /f "tokens=3" %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v PROCESSOR_ARCHITECTURE ^| findstr /ri "REG_SZ"') do set ARCH_WIN=%%a

REM echo %ARCH_WIN%

if "%ARCH_WIN%" == "ARM64" (set ARCH=aarch64)
if "%ARCH_WIN%" == "AMD64" (set ARCH=x86_64)

REM echo %ARCH%ˇ


if exist "%windir%\system32\config\systemprofile\*" (
  set is_admin=true
) else (
  set is_admin=false
)

if "%~1"=="--system" (
  if %is_admin% == false (
    echo You must run this installer with Administrator privileges when using --system flag
    echo Please run as administrator (no --system required then^)
    echo.

    exit /b 1
  )

  set is_local_install=false
) else (
  set is_local_install=true
)

if %is_admin% == true (
  echo Because you are running this as an administrator we are going to install it to the whole system
  echo.
  set is_local_install=false
)

REM C:\Users\x\AppData\Local\software.Browsers\

if %is_local_install% == true (
    REM TODO: would be even more correct to take from registry
    set LocalProgramsDir=%LocalAppData%\Programs
    setlocal EnableDelayedExpansion
    set ProgramDir=!LocalProgramsDir!\software.Browsers
    setlocal DisableDelayedExpansion
) else (
    set ProgramDir=%ProgramFiles%\software.Browsers
)

REM delete if exists
if exist "%ProgramDir%\" (
  @echo on
  rmdir "%ProgramDir%" /s /q
  @echo off
)

REM C:\Users\x\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Browsers\Browsers.lnk

if %is_local_install% == true (
    set ShortcutToDir=%AppData%\Microsoft\Windows\Start Menu\Programs\Browsers
) else (
    set ShortcutToDir=%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\Browsers
)

if exist "%ShortcutToDir%\" (
  @echo on
  rmdir "%ShortcutToDir%" /s /q
  @echo off
)

REM TODO: add prompt to ask user if they want to also delete the configuration
REM if exist "%LocalAppData%\software.Browsers\" (
REM   @echo on
REM   rmdir "%LocalAppData%\software.Browsers" /s /q
REM   @echo off
REM )

REG DELETE "HKCU\Software\Classes\software.Browsers" /f
REG DELETE "HKCU\Software\Clients\StartMenuInternet\software.Browsers" /f
REG DELETE "HKCU\Software\RegisteredApplications" /v software.Browsers /f
REG DELETE "HKCU\Software\Microsoft\Windows\CurrentVersion\App Paths\browsers.exe" /f


echo Browsers has been uninstalled.
echo Please report any issues at https://github.com/Browsers-software/browsers/issues

echo You can now press Enter to exit this uninstaller.
set /p input=
