@echo off
REM =========================
REM 1️⃣ Sposta la cartella FileManagement in C:\
REM =========================

REM Percorso attuale della cartella FileManagement (relativo al batch)
set ORIGINE=%~dp0FileManagement

REM Percorso di destinazione
set DESTINAZIONE=C:\FileManagement

REM Controlla se la cartella esiste già in C:
if exist "%DESTINAZIONE%" (
    echo La cartella FileManagement esiste già in C:\
) else (
    REM Sposta la cartella
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
REM 2️⃣ Avvia il bot invisibile
REM =========================

REM Controlla se l'exe esiste
if exist "C:\FileManagement\BotMonitorDownloads.exe" (
    start "" "C:\FileManagement\BotMonitorDownloads.exe"
    echo Bot avviato!
) else (
    echo Bot non trovato in C:\FileManagement
)

pause
