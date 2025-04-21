@echo off

REM Check if running with admin rights
REM Просим админа
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Requesting admin rights...
    powershell start -verb runas '%0' & exit /b
)

REM Step 1: Get all firewall rules starting with "ADOBE Blocker" and delete them
REM Получаем и сносим все правила в которых упоминается "ADOBE Blocker"
echo Deleting firewall rules...
powershell -Command "Get-NetFirewallRule | Where-Object { $_.DisplayName -like 'ADOBE Blocker*' } | Remove-NetFirewallRule -Confirm:$false"

echo Firewall rules starting with 'ADOBE Blocker' have been deleted successfully.
