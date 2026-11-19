# Playbook: Sicherheitsvorfall auf einem Arbeitsplatz bearbeiten

Gilt für Alarme ab Stufe 10 (Wazuh) bzw. hoher Einstufung (Sophos). Aufbau angelehnt an die Phasen nach NIST SP 800-61.

## 1. Erkennen und einordnen (Ziel: 15 Minuten)

- [ ] Alarm öffnen: Regel, Stufe, Gerät, Benutzer, Zeitpunkt notieren
- [ ] Ist es ein bekannter Test oder Fehlalarm? Mit Änderungs- und Testkalender abgleichen
- [ ] Schwere festlegen: niedrig / mittel / hoch / kritisch
- [ ] Ticket anlegen und alle weiteren Schritte dort dokumentieren

## 2. Eindämmen

- [ ] Bei hoher Schwere: Gerät isolieren (Sophos: Gerät isolieren; Wazuh: Active Response oder Netzwerk trennen)
- [ ] Betroffenes Konto sperren bzw. Kennwort zurücksetzen und Sitzungen beenden
- [ ] Benutzer informieren: Gerät nicht ausschalten, nichts löschen

## 3. Untersuchen

- [ ] Prozesskette und Ursprung klären (Sophos Root Cause, Wazuh Threat Hunting)
- [ ] Gleiche Indikatoren auf anderen Geräten suchen (Hash, Befehlszeile, Ziel-IP)
- [ ] Zeitlinie der Ereignisse festhalten

## 4. Beseitigen und wiederherstellen

- [ ] Schadkomponente entfernen oder Gerät neu aufsetzen
- [ ] Gerät erst nach Prüfung wieder ins Netz lassen
- [ ] Überwachung des Geräts für einige Tage verschärfen

## 5. Nachbereiten

- [ ] Kurzbericht: Was ist passiert, wie wurde es erkannt, was wurde getan?
- [ ] Prüfen, ob eine Meldepflicht besteht (z. B. Datenschutzverletzung nach DSGVO, Frist 72 Stunden)
- [ ] Verbesserungen ableiten: neue Regel, Richtlinie, Schulung
