# 3. Agenten und Sysmon einrichten

## Wazuh-Agent auf Windows 11

Den passenden Installationsbefehl erzeugt das Dashboard selbst: **Agents management → Summary → Deploy new agent**. Dort Windows wählen, als Serveradresse `10.10.10.10` eintragen und den angezeigten PowerShell-Befehl auf `client01` als Administrator ausführen. So stimmt die Agentenversion immer mit dem Server überein.

Danach den Dienst starten:

```powershell
NET START Wazuh
```

## Sysmon installieren

Sysmon (Microsoft Sysinternals) protokolliert Prozessstarts, Netzwerkverbindungen und weitere Ereignisse deutlich genauer als das Standard-Ereignisprotokoll. Ohne Sysmon sieht Wazuh zum Beispiel keine vollständigen Befehlszeilen.

1. Sysmon von [Microsoft Learn](https://learn.microsoft.com/sysinternals/downloads/sysmon) herunterladen.
2. Eine bewährte Konfiguration verwenden, zum Beispiel [SwiftOnSecurity/sysmon-config](https://github.com/SwiftOnSecurity/sysmon-config).
3. Installieren:

```powershell
.\Sysmon64.exe -accepteula -i sysmonconfig-export.xml
```

## Agent anweisen, die Ereignisse zu lesen

Den Ausschnitt aus [config/agent-windows-ossec.conf](../config/agent-windows-ossec.conf) in `C:\Program Files (x86)\ossec-agent\ossec.conf` innerhalb von `<ossec_config>` einfügen und den Agenten neu starten:

```powershell
Restart-Service -Name Wazuh
```

Damit liest der Agent zusätzlich:

- Sysmon (Prozessstarts, Netzwerk)
- PowerShell-Protokoll (Skriptblöcke)
- Microsoft Defender (Erkennungen)

## PowerShell-Skriptblockprotokollierung aktivieren

Über Gruppenrichtlinie oder lokal auf `client01`:

```powershell
$key = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging"
New-Item -Path $key -Force | Out-Null
Set-ItemProperty -Path $key -Name EnableScriptBlockLogging -Value 1
```

## Prüfen

- Im Dashboard muss `client01` als **active** erscheinen.
- Bericht per Skript: [scripts/Get-WazuhAgentStatus.ps1](../scripts/Get-WazuhAgentStatus.ps1)

## Notizen

20.11.2026: Alte Windows-VMs unbrauchbar, Windows 11 Multi-Edition (Evaluierungsversion) als ISO für client01 heruntergeladen.
