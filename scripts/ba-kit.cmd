@echo off
REM BA-kit CLI wrapper for Windows
REM Invokes the bash script through Git Bash or WSL bash
setlocal enabledelayedexpansion

set "SCRIPT_DIR=%~dp0"
set "BA_KIT_SCRIPT=%SCRIPT_DIR%ba-kit"

REM Prefer Git Bash (most common for BA-kit users)
for %%p in (
  "C:\Program Files\Git\bin\bash.exe"
  "C:\Program Files (x86)\Git\bin\bash.exe"
  "%LOCALAPPDATA%\Programs\Git\bin\bash.exe"
) do (
  if exist %%p (
    %%p -c "export HOME='%USERPROFILE%'; '%BA_KIT_SCRIPT%' %*"
    exit /b %ERRORLEVEL%
  )
)

REM Fallback: WSL bash
where wsl >nul 2>&1
if %ERRORLEVEL% equ 0 (
  wsl bash -c "export HOME='%USERPROFILE%'; '%BA_KIT_SCRIPT%' %*"
  exit /b %ERRORLEVEL%
)

echo ERROR: Cannot find bash. Install Git for Windows from https://git-scm.com
exit /b 1
