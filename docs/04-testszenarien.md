# 4. Testszenarien

Alle Szenarien werden mit [scripts/Invoke-LabTestScenario.ps1](../scripts/Invoke-LabTestScenario.ps1) auf `client01` ausgelöst und sind harmlos.

```powershell
.\Invoke-LabTestScenario.ps1 -Scenario All -ConfirmLab
```

## Übersicht

| Nr. | Szenario | MITRE ATT&CK | Erwartete Erkennung | Wazuh | Sophos XDR |
| --- | --- | --- | --- | --- | --- |
| T1 | EICAR-Testdatei | – | Virenschutz-Fund | erkannt (Regel 62123, Stufe 12) | offen |
| T2 | 6 fehlgeschlagene Anmeldungen | T1110 Brute Force | Regel 60122, eigene Regel 100110 | offen | offen |
| T3 | Kodierter PowerShell-Befehl | T1059.001, T1027 | Sysmon-Ereignis 1, eigene Regel 100100 | offen | offen |

„offen“ nach dem Test ersetzen durch: erkannt (Regel/Alarm), teilweise oder nicht erkannt.

## Vorlage je Test

### T1 – EICAR-Testdatei

- **Datum/Uhrzeit:** 21.11.2026, 00:15 Uhr
- **Ausgelöst auf:** client01 (`Invoke-LabTestScenario.ps1 -Scenario Eicar -ConfirmLab`)
- **Erkannt durch:** Microsoft Defender auf client01; das Ereignis wurde über den Wazuh-Agenten (Kanal `Microsoft-Windows-Windows Defender/Operational`) an den Server gemeldet.
- **Alarm/Regel-ID und Stufe:**
  - 00:15:39 – Regel **62123**, Stufe **12**: „Windows Defender: Antimalware platform detected potentially unwanted software“
  - 00:15:59 – Regel **62124**, Stufe 3: „… performed an action to protect you from potentially unwanted software“ (Datei entfernt)
  - Daneben mehrere Ereignisse der Regel 62154 (Stufe 5, „feature configuration changed“)
- **Zeit bis zur Meldung:** wenige Sekunden; Erkennung und Gegenmaßnahme lagen 20 Sekunden auseinander.
- **Screenshot:** ![Defender-Alarme zu T1 in Wazuh](img/t1-wazuh.png)
- **Erkenntnis:** Wazuh übernimmt die Defender-Meldungen zuverlässig und stuft den Fund mit Stufe 12 als kritisch ein. In der Kurzbeschreibung bleibt der Name der Bedrohung leer („()“); er steht nur in den Detailfeldern des Ereignisses. Für eine schnelle Bewertung im Alltag wäre eine eigene Regel mit dem Bedrohungsnamen in der Beschreibung hilfreich. Die Häufung von „feature configuration changed“ zeigt außerdem, dass Defender-Ereignisse ohne Filter schnell Rauschen erzeugen.

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
