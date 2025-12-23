@echo off
REM =========================
REM 1️⃣ Sposta la cartella FileManagement in C:\
REM =========================

set ORIGINE=%~dp0FileManagement
set DESTINAZIONE=C:\FileManagement

if exist "%DESTINAZIONE%" (
    echo La cartella FileManagement esiste già in C:\
) else (
    move "%ORIGINE%" "%DESTINAZIONE%"
    if exist "%DESTINAZIONE%" (
        echo Cartella spostata con successo in C:\
    ) else (
        echo Errore nello spostamento della cartella.
        pause
        exit
    )
)

REM =========================
REM 2️⃣ Avvia InstallaStartup.bat
REM =========================

if exist "C:\FileManagement\InstallaStartup.bat" (
    echo Avvio installazione avvio automatico...
    call "C:\FileManagement\InstallaStartup.bat"
) else (
    echo InstallaStartup.bat non trovato
)

REM =========================
REM 3️⃣ Avvia il bot
REM =========================

if exist "C:\FileManagement\BotMonitorDownloads.exe" (
    start "" "C:\FileManagement\BotMonitorDownloads.exe"
    echo Bot avviato!
) else (
    echo Bot non trovato in C:\FileManagement
)

pause
