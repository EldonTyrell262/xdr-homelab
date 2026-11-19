# 4. Testszenarien

Alle Szenarien werden mit [scripts/Invoke-LabTestScenario.ps1](../scripts/Invoke-LabTestScenario.ps1) auf `client01` ausgelöst und sind harmlos.

```powershell
.\Invoke-LabTestScenario.ps1 -Scenario All -ConfirmLab
```

## Übersicht

| Nr. | Szenario | MITRE ATT&CK | Erwartete Erkennung | Wazuh | Sophos XDR |
| --- | --- | --- | --- | --- | --- |
| T1 | EICAR-Testdatei | – | Virenschutz-Fund | offen | offen |
| T2 | 6 fehlgeschlagene Anmeldungen | T1110 Brute Force | Regel 60122, eigene Regel 100110 | offen | offen |
| T3 | Kodierter PowerShell-Befehl | T1059.001, T1027 | Sysmon-Ereignis 1, eigene Regel 100100 | offen | offen |

„offen“ nach dem Test ersetzen durch: erkannt (Regel/Alarm), teilweise oder nicht erkannt.

## Vorlage je Test

### T1 – EICAR-Testdatei

- **Datum/Uhrzeit:**
- **Ausgelöst auf:** client01
- **Erkannt durch:**
- **Alarm/Regel-ID und Stufe:**
- **Zeit bis zur Meldung:**
- **Screenshot:** `docs/img/t1-wazuh.png` (ohne persönliche Daten)
- **Erkenntnis:**

### T2 – Fehlgeschlagene Anmeldungen

- **Datum/Uhrzeit:**
- **Erkannt durch:**
- **Alarm/Regel-ID und Stufe:**
- **Erkenntnis:**

### T3 – Kodierter PowerShell-Befehl

- **Datum/Uhrzeit:**
- **Erkannt durch:**
- **Alarm/Regel-ID und Stufe:**
- **Erkenntnis:**
