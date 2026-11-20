<#
.SYNOPSIS
    Erstellt einen Statusbericht aller Wazuh-Agenten über die Wazuh-API.

.DESCRIPTION
    Meldet sich an der Wazuh-API an, liest alle Agenten aus und gibt Name, IP,
    Betriebssystem, Version, Status und letzten Kontakt aus. Optional als CSV.
    Agenten, die nicht "active" sind, werden farbig hervorgehoben.

.PARAMETER Server
    Adresse des Wazuh-Servers, Standard 10.10.10.10.

.PARAMETER CsvPath
    Optionaler Pfad für einen CSV-Export.

.EXAMPLE
    .\Get-WazuhAgentStatus.ps1 -Server 10.10.10.10 -CsvPath .\agenten.csv

.NOTES
    Benötigt PowerShell 7 (wegen -SkipCertificateCheck für das selbstsignierte
    Laborzertifikat). In produktiven Umgebungen ein gültiges Zertifikat verwenden.
    Zugangsdaten werden abgefragt und nicht gespeichert.
#>
[CmdletBinding()]
param(
    [string]$Server = "10.10.10.10",
    [int]$Port = 55000,
    [string]$CsvPath
)

#Requires -Version 7.0
$ErrorActionPreference = "Stop"
$baseUri = "https://${Server}:${Port}"

$credential = Get-Credential -Message "Wazuh-API-Benutzer (z. B. wazuh)"

try {
    $auth = Invoke-RestMethod -Method Post -Uri "$baseUri/security/user/authenticate" `
        -Authentication Basic -Credential $credential -SkipCertificateCheck
    $headers = @{ Authorization = "Bearer $($auth.data.token)" }

    $response = Invoke-RestMethod -Method Get -Uri "$baseUri/agents?limit=500" `
        -Headers $headers -SkipCertificateCheck
}
catch {
    Write-Error "Abfrage der Wazuh-API fehlgeschlagen: $($_.Exception.Message)"
    exit 1
}

$agents = $response.data.affected_items | ForEach-Object {
    [pscustomobject]@{
        ID            = $_.id
        Name          = $_.name
        IP            = $_.ip
        Betriebssystem = "$($_.os.name) $($_.os.version)".Trim()
        Version       = $_.version
        Status        = $_.status
        LetzterKontakt = $_.lastKeepAlive
    }
}

foreach ($agent in $agents) {
    $color = if ($agent.Status -eq "active") { "Green" } else { "Yellow" }
    Write-Host ("{0,-4} {1,-15} {2,-15} {3,-12} {4}" -f $agent.ID, $agent.Name, $agent.IP, $agent.Status, $agent.Betriebssystem) -ForegroundColor $color
}

$inactive = @($agents | Where-Object Status -ne "active")
Write-Host ""
Write-Host "Agenten gesamt: $($agents.Count), davon nicht aktiv: $($inactive.Count)"

if ($CsvPath) {
    $agents | Export-Csv -Path $CsvPath -NoTypeInformation -Encoding UTF8
    Write-Host "CSV gespeichert: $CsvPath"
}
