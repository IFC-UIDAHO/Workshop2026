@echo off
REM ============================================================
REM IFC Workshop 2026 - GitHub Deploy Script
REM Pushes this folder straight to GitHub Pages
REM ============================================================
REM Usage: Just double-click this file, or run from cmd:
REM        deploy.bat
REM ============================================================

echo.
echo  ============================================
echo   IFC Workshop 2026 - GitHub Deploy
echo  ============================================
echo.

REM --- Configuration ---
set REPO_URL=https://github.com/IFC-UIDAHO/Workshop2026.git
set BRANCH=main

REM --- Check if git is installed ---
git --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Git is not installed or not in PATH.
    echo          Download from: https://git-scm.com/download/win
    pause
    exit /b 1
)

REM --- Work from the folder this .bat file lives in ---
cd /d "%~dp0"

REM --- Trust this folder (network/mapped drives don't record ownership,
REM     which makes Git refuse to run here otherwise) ---
git config --global --add safe.directory "%CD%"
set "CD_FWD=%CD:\=/%"
git config --global --add safe.directory "%CD_FWD%"

if not exist "index.html" (
    echo [ERROR] Could not find index.html in this folder.
    echo          Make sure deploy.bat stays in the Workshop2026 folder.
    pause
    exit /b 1
)

echo [1/5] Found site folder: %~dp0

REM --- Initialize git if needed ---
if not exist ".git\" (
    echo [2/5] Initializing Git repository...
    git init
    git branch -M %BRANCH%
    git remote add origin %REPO_URL%
) else (
    echo [2/5] Git repository already initialized.
)

REM --- Ensure remote is set ---
git remote get-url origin >nul 2>&1
if errorlevel 1 (
    echo         Adding remote origin...
    git remote add origin %REPO_URL%
)

REM --- Clear a stale lock file if a previous run was interrupted ---
if exist ".git\index.lock" del /f /q ".git\index.lock"

echo [3/5] Staging all files...
git add -A

echo [4/5] Committing changes...
git commit -m "Update IFC Workshop 2026 site - %date% %time%" >nul 2>&1
if errorlevel 1 (
    echo         No changes to commit, or commit already exists.
)

echo [5/5] Pushing to GitHub (%BRANCH%)...
git push -u origin %BRANCH%
if errorlevel 1 (
    echo.
    echo [WARNING] Push failed. Common causes:
    echo           - Repository does not exist on GitHub yet
    echo           - No write access to IFC-UIDAHO/Workshop2026
    echo           - Authentication required ^(use PAT or SSH^)
    echo.
    echo           To create the repo, visit:
    echo           https://github.com/new?name=Workshop2026^&owner=IFC-UIDAHO
    echo.
    pause
    exit /b 1
)

echo.
echo  ============================================
echo   SUCCESS! Site pushed to GitHub.
echo  ============================================
echo.
echo   Repository: %REPO_URL%
echo.
echo   Next steps to publish:
echo   1. Go to: https://github.com/IFC-UIDAHO/Workshop2026/settings/pages
echo   2. Under "Source", select "Deploy from a branch"
echo   3. Choose branch: %BRANCH%
echo   4. Select folder: / (root)
echo   5. Click "Save"
echo   6. Your site will be live at:
echo      https://IFC-UIDAHO.github.io/Workshop2026
echo.
pause
