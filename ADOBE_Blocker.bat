REM Сосал?

@echo off
setlocal enabledelayedexpansion

REM Check if running with admin rights
REM Просим админа
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Requesting admin rights...
    powershell start -verb runas '%0' & exit /b
)

REM Folder picker window using PowerShell
REM Окно выборка папки через PS
for /f "usebackq delims=" %%I in (`powershell -Command "Add-Type -AssemblyName System.Windows.Forms; $FolderBrowse = New-Object System.Windows.Forms.FolderBrowserDialog; $null = $FolderBrowse.ShowDialog(); $FolderName = $FolderBrowse.SelectedPath; Write-Output $FolderName"`) do (
    set selectedFolder="%%~fI"
)

REM Check if a folder was selected
REM Проверка, если папка не выбрана, выходим
if not defined selectedFolder (
    echo No folder selected. Exiting...
    exit /b
)

REM Define hardcoded folders as separate variables
REM Захардкоженые стандартные пути акробатовского шлака
set PF_ADOBE="C:\Program Files\Adobe"
set PF_CF_ACROBATDC="C:\Program Files\Adobe\Acrobat DC"
set PF86_ADOBE="C:\Program Files (x86)\Adobe"
set PF86_CF_ACROBATDC="C:\Program Files (x86)\Adobe\Acrobat DC"
set PD_ACROBAT="C:\ProgramData\Adobe\Acrobat"
set PD_ADOBE="C:\ProgramData\Adobe"
set USER_APPDATA_ROAMING_ACROBAT="%USERPROFILE%\AppData\Roaming\Adobe\Acrobat"
set USER_APPDATA_ROAMING_ADOBE="%USERPROFILE%\AppData\Roaming\Adobe"

REM Combine hardcoded folders into a list
REM Обьединение хардкоженных папок в лист "folders"
set folders=%selectedFolder%;%PF_ADOBE%;%PF_CF_ACROBATDC%;%PF86_ADOBE%;%PF86_CF_ACROBATDC%;%PD_ACROBAT%;%PD_ADOBE%;%USER_APPDATA_ROAMING_ACROBAT%;%USER_APPDATA_ROAMING_ADOBE%

REM Add outbound and inbound rules for executables in the hardcoded paths
REM Добавляем входящие и исходящие запросы в исключения фаервола по хардкоженных путям
echo Adding firewall rules for executables in the %folders%:
for %%F in (%folders%) do (
    REM Check if the hardcoded path exists
	REM Проверка на наличие хардкоженных путей
    if exist %%F (
        echo Processing: %%F
        cd /D %%F
        for /r %%I in (*.exe) do (
            echo Blocking EXE %%~fI
            netsh advfirewall firewall add rule name="ADOBE Blocker %%~nI" dir=out action=block program="%%~fI"
            netsh advfirewall firewall add rule name="ADOBE Blocker %%~nI" dir=in action=block program="%%~fI"
        )
    ) else (
        echo Skipped: %%F (Folder does not exist)
    )
)

echo Firewall rules added successfully.
pause
