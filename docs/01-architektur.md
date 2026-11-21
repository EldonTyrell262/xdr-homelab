# 1. Architektur und Hyper-V-Netz

## Ziel

Eine kleine, abgeschottete Umgebung, in der Agenten Ereignisse an einen zentralen Server melden. Der Host hat 40 GB RAM, damit laufen alle drei VMs gleichzeitig.

## Netz

| Element | Wert |
| --- | --- |
| Hyper-V-Switch | `LabSwitch`, intern |
| Netz | 10.10.10.0/24 |
| Gateway (Host, NAT) | 10.10.10.1 |
| `wazuh01` | 10.10.10.10 |
| `srv01` | 10.10.10.20 |
| `client01` | 10.10.10.50 |

## Switch und NAT anlegen (PowerShell als Administrator auf dem Host)

```powershell
New-VMSwitch -SwitchName "LabSwitch" -SwitchType Internal
$ifIndex = (Get-NetAdapter -Name "vEthernet (LabSwitch)").ifIndex
New-NetIPAddress -IPAddress 10.10.10.1 -PrefixLength 24 -InterfaceIndex $ifIndex
New-NetNat -Name "LabNat" -InternalIPInterfaceAddressPrefix 10.10.10.0/24
```

Die VMs bekommen feste IP-Adressen mit Gateway 10.10.10.1. Über NAT erreichen sie das Internet für Updates und Paketinstallation, sind aber von außen nicht erreichbar.

## Datenfluss

```
client01 / srv01  --(Agent, TCP 1514/1515)-->  wazuh01  --(HTTPS 443)-->  Browser auf dem Host
                                                  |
                                          Wazuh-API (TCP 55000)  <--  PowerShell-Bericht
```

| Port | Zweck |
| --- | --- |
| 1514/TCP | Ereignisse der Agenten an den Server |
| 1515/TCP | Registrierung neuer Agenten |
| 55000/TCP | Wazuh-API |
| 443/TCP | Wazuh-Dashboard |

## Notizen

**20.11.2026 – Ist-Stand:** Für den Start hängt `wazuh01` am Hyper-V-Standardswitch (*Default Switch*) statt am geplanten `LabSwitch`.

| Element | Wert |
| --- | --- |
| Switch | Hyper-V *Default Switch* (NAT, DHCP) |
| Netz | 172.17.64.0/20 |
| Gateway | 172.17.64.1 |
| `wazuh01` | 172.17.71.77 (per DHCP) |

- Vorteil: sofort einsatzbereit, kein eigener Switch nötig.
- Nachteil: Der Default Switch vergibt Adressen per DHCP; nach einem Neustart des Hosts kann sich die IP ändern. Die Agenten brauchen aber eine feste Adresse des Servers. Deshalb ist der Umzug auf `LabSwitch` mit festen IPs (siehe oben) weiterhin geplant.
- Der DNS-Dienst des Default Switch (172.17.64.1) hat Namen nur sehr langsam oder gar nicht aufgelöst. Lösung siehe [02-wazuh-installation.md](02-wazuh-installation.md#notizen).

**21.11.2026 – Fehlersuche: `client01` ohne Internet nach Neuaufbau**

`client01` wurde neu aufgesetzt (VHDX jetzt auf der USB-SSD unter `D:\Hyper-V`), feste IP 10.10.10.50 am `LabSwitch`. Weder das Gateway noch Ziele im Internet waren erreichbar.

- Ursache: Auf dem Host existierte noch ein älteres NAT `nat-outside` für 20.20.20.0/24 (Switch `nat-intern`, Host-IP 20.20.20.1), das keine VM mehr nutzte. Das NAT `LabNat` für 10.10.10.0/24 fehlte. Windows erlaubt pro Host nur ein NAT (`New-NetNat`), deshalb hatte das Labornetz keinen Weg nach außen.
- Diagnose auf dem Host: `Get-NetNat`, `Get-NetIPAddress -AddressFamily IPv4`, `Get-VM | Get-VMNetworkAdapter | Select VMName, SwitchName, IPAddresses`
- Lösung:

```powershell
Remove-NetNat -Name "nat-outside" -Confirm:$false
New-NetNat -Name "LabNat" -InternalIPInterfaceAddressPrefix 10.10.10.0/24
```

- Hinweis zum Testen: `ping 10.10.10.1` bleibt auch bei funktionierendem Netz ohne Antwort, weil die Windows-Firewall des Hosts eingehende Pings blockt. Aussagekräftiger ist `ping 1.1.1.1` bzw. `ping google.de` aus der VM.
- Ergebnis: `client01` erreicht das Internet über `LabNat`. Als Nächstes folgt der Umzug von `wazuh01` auf `LabSwitch` (10.10.10.10).

**21.11.2026 – `wazuh01` auf `LabSwitch` umgezogen, Host-IP nachgetragen**

Damit Server und Agent im selben Netz liegen, wurde `wazuh01` vom *Default Switch* auf `LabSwitch` umgehängt und bekam die feste IP 10.10.10.10 (Gateway 10.10.10.1, DNS 1.1.1.1 und 8.8.8.8). Die Tabelle oben zum Ist-Stand vom 20.11.2026 ist damit überholt; das Netz entspricht jetzt der Planung.

```powershell
Connect-VMNetworkAdapter -VMName wazuh01 -SwitchName "LabSwitch"
```

- Problem: Der Host erreichte `wazuh01` weder per Ping noch per SSH. `Test-NetConnection 10.10.10.10 -Port 22` zeigte als Schnittstelle `vEthernet (Extern)` mit einer Absenderadresse aus dem externen Netz. Der Host kannte also keinen direkten Weg ins Labornetz.
- Ursache: Die Host-Adresse 10.10.10.1 auf `vEthernet (LabSwitch)` fehlte. Lösung:

```powershell
New-NetIPAddress -IPAddress 10.10.10.1 -PrefixLength 24 -InterfaceAlias "vEthernet (LabSwitch)"
```

- Auf `wazuh01` geprüft, dass `firewalld` (Zone `public`) `ssh` und die Ports 443, 1514, 1515 und 55000/TCP erlaubt (`sudo firewall-cmd --list-all`).
- Ergebnis: SSH vom Host auf `wazuh01` funktioniert, `wazuh01` erreicht das Internet über `LabNat`. Dass `ping 10.10.10.50` von `wazuh01` aus scheitert, ist erwartet: Die Windows-Firewall auf `client01` blockt eingehende Pings. Der Agent baut die Verbindung selbst zum Server auf.
