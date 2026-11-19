# 5. Sophos XDR (30-Tage-Test)

Die Testversion erst starten, wenn Labor und Wazuh laufen, damit die 30 Tage voll für Sophos genutzt werden.

Testversion: [Sophos XDR Free Trial](https://www.sophos.com/de-de/content/xdr-free-trial)

## Ablauf

1. Sophos-Central-Konto für den Test anlegen.
2. In Sophos Central den Endpoint-Installer herunterladen und auf `client01` installieren.
3. Hinweis: Neben Sophos sollte kein zweiter aktiver Virenschutz laufen. Microsoft Defender schaltet sich bei der Installation in der Regel selbst in den passiven Modus. Der Wazuh-Agent ist kein Virenschutz und kann parallel laufen.
4. Standardrichtlinien prüfen und dokumentieren: Bedrohungsschutz, Manipulationsschutz, Webschutz.
5. Testszenarien aus [04-testszenarien.md](04-testszenarien.md) wiederholen und die Spalte „Sophos XDR“ ausfüllen.

## Was ich in Sophos Central untersuchen will

- [ ] Erkennungen (Detections) und deren Einstufung
- [ ] Fallansicht (Cases) und Ursachenanalyse (Root Cause)
- [ ] Gerät isolieren und wieder freigeben
- [ ] Live Discover: eigene Abfragen auf dem Endpunkt
- [ ] Richtlinie anpassen, zum Beispiel Anwendungskontrolle
- [ ] Manipulationsschutz testen: Lässt sich der Dienst ohne Passwort stoppen?

## Beispielabfragen für Live Discover (osquery-SQL)

PowerShell-Prozesse mit kodiertem Befehl:

```sql
SELECT pid, name, path, cmdline
FROM processes
WHERE lower(name) LIKE 'powershell%'
  AND lower(cmdline) LIKE '%-enc%';
```

Lauschende Netzwerkports und zugehörige Programme:

```sql
SELECT p.name, p.path, l.port, l.address
FROM listening_ports l
JOIN processes p USING (pid)
WHERE l.port <> 0;
```

## Notizen

_Ergebnisse, Screenshots (ohne persönliche Daten) und Eindrücke hier festhalten._
