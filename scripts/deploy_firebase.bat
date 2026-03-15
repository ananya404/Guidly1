@echo off
echo Starting Firebase Deployment for Guidly...

REM Check if firebase CLI is installed
where firebase >nul 2>nul
if %errorlevel% neq 0 (
    echo Firebase CLI is not installed. Please run "npm install -g firebase-tools"
    exit /b 1
)

echo Deploying Firestore Rules and Indexes...
call firebase deploy --only firestore

echo Deploying Storage Rules...
call firebase deploy --only storage

echo Deploying Cloud Functions...
call firebase deploy --only functions

echo Deployment Complete!
pause
