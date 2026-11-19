<#
.SYNOPSIS
    Löst harmlose Testereignisse aus, um die Erkennung von Wazuh und Sophos XDR zu prüfen.

.DESCRIPTION
    Nur für die isolierte Laborumgebung gedacht. Es wird keine Schadsoftware verwendet.

    Szenarien:
      Eicar         Legt die EICAR-Testdatei an. Virenscanner erkennen sie absichtlich.
      FailedLogon   Erzeugt mehrere fehlgeschlagene Anmeldungen (Ereignis 4625).
      EncodedPS     Startet PowerShell mit einem kodierten, harmlosen Befehl.

    Jedes Szenario gibt Startzeit und erwartete Erkennung aus, damit das Ergebnis
    in docs/04-testszenarien.md dokumentiert werden kann.

.PARAMETER Scenario
    Eicar, FailedLogon, EncodedPS oder All.

.PARAMETER ConfirmLab
    Muss gesetzt werden. Bestätigt, dass das Skript in der Laborumgebung läuft.

.EXAMPLE
    .\Invoke-LabTestScenario.ps1 -Scenario EncodedPS -ConfirmLab
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateSet("Eicar", "FailedLogon", "EncodedPS", "All")]
    [string]$Scenario,

    [switch]$ConfirmLab
)

if (-not $ConfirmLab) {
    Write-Warning "Abbruch: Dieses Skript nur im Labor ausführen und mit -ConfirmLab bestätigen."
    exit 1
}

function Write-Start($name, $expected) {
    Write-Host ""
    Write-Host "=== $name ===" -ForegroundColor Cyan
    Write-Host "Start: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    Write-Host "Erwartet: $expected"
}

function Invoke-Eicar {
    Write-Start "EICAR-Testdatei" "Defender-Erkennung (Ereignis 1116/1117), Alarm in Wazuh bzw. Sophos"
    # Der EICAR-String wird zusammengesetzt, damit dieses Skript selbst nicht als Fund gilt.
    $eicar = 'X5O!P%@AP[4\PZX54(P^)7CC)7}' + '$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$H+H*'
    $path = Join-Path $env:TEMP "eicar-test.com"
    try {
        Set-Content -Path $path -Value $eicar -NoNewline -Encoding ascii
        Write-Host "Datei geschrieben: $path (wird normalerweise sofort entfernt)"
    }
    catch {
        Write-Host "Schreiben blockiert, der Virenschutz hat reagiert: $($_.Exception.Message)" -ForegroundColor Green
    }
}

function Invoke-FailedLogon {
    Write-Start "Fehlgeschlagene Anmeldungen" "Ereignis 4625, Wazuh-Regel 60122, ab 5 Versuchen Regel 100110"
    $user = "labtest-user"
    1..6 | ForEach-Object {
        $null = cmd /c "net use \\localhost\IPC$ /user:$user FalschesPasswort$_ 2>&1"
        Start-Sleep -Seconds 2
    }
    Write-Host "6 Anmeldeversuche mit falschem Passwort für '$user' ausgeführt."
}

function Invoke-EncodedPS {
    Write-Start "Kodierter PowerShell-Befehl" "Sysmon-Ereignis 1, Wazuh-Regel 100100"
    $command = "Write-Output 'Harmloser Labortest'"
    $encoded = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($command))
    powershell.exe -NoProfile -EncodedCommand $encoded
}

switch ($Scenario) {
    "Eicar"       { Invoke-Eicar }
    "FailedLogon" { Invoke-FailedLogon }
    "EncodedPS"   { Invoke-EncodedPS }
    "All"         { Invoke-Eicar; Invoke-FailedLogon; Invoke-EncodedPS }
}

Write-Host ""
Write-Host "Fertig. Jetzt im Dashboard unter Threat Hunting bzw. in Sophos Central prüfen und das Ergebnis dokumentieren."
