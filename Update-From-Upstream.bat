@echo off
setlocal EnableExtensions DisableDelayedExpansion
pushd "%~dp0" || exit /b 1
set "result=1"
if not "%~1"=="" if not "%~1"=="--no-push" (
    echo Usage: Update-From-Upstream.bat [--no-push]
    goto finish
)
where git >nul 2>&1
if errorlevel 1 (
    echo Git is missing. Install Git for Windows first.
    goto finish
)
git rev-parse --show-toplevel >nul 2>&1
if errorlevel 1 (
    echo Run this file from inside your ReSkatePrivacy source checkout.
    goto finish
)
set "branch="
for /f "delims=" %%B in ('git branch --show-current') do set "branch=%%B"
if not "%branch%"=="main" (
    echo Switch to main first: git switch main
    goto finish
)
git status --porcelain >nul
if errorlevel 1 goto finish
set "dirty="
for /f "delims=" %%S in ('git status --porcelain') do set "dirty=yes"
if defined dirty (
    echo Commit or stash your local changes first, including any unfinished merge.
    goto finish
)
if not exist "Fork\steam_privacy.h" (
    echo The Steam privacy module is missing. Restore it before updating.
    goto finish
)
echo Fetching the original ReSkate main...
git fetch https://github.com/Dingo-Shenanigans/ReSkate.git refs/heads/main:refs/remotes/upstream/main
if errorlevel 1 goto finish
echo Merging original updates into your local main...
git merge --no-edit upstream/main
if errorlevel 1 (
    echo.
    echo The merge stopped. Run git status to see what needs attention.
    echo Resolve conflicts while keeping the privacy module and its guards.
    echo Then run git add for the resolved files and git commit.
    echo Rebuild and check the privacy changes before running this file again.
    echo Nothing was pushed.
    goto finish
)
if "%~1"=="--no-push" (
    echo Merge finished locally. Nothing was pushed.
    set "result=0"
    goto finish
)
echo Pushing only to Ehren1337/ReSkatePrivacy main...
git push https://github.com/Ehren1337/ReSkatePrivacy.git HEAD:refs/heads/main
if errorlevel 1 (
    echo Push failed. Your merged work remains locally; nothing was force-pushed.
    goto finish
)
echo Done. No pull request was created.
echo Rebuild before using the updated mod. Review new Steam download code after updates.
set "result=0"
:finish
popd
if not defined RESKATE_SYNC_NO_PAUSE pause
exit /b %result%
