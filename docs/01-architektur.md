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

## Ausbaustufe: getrennte Netze mit Router/Firewall

Nach dem ersten Durchlauf wird das flache Netz aufgeteilt. Das entspricht einer üblichen Firmenstruktur und zeigt Netzwerkkenntnisse.

| Netz | Switch | Bereich | VMs |
| --- | --- | --- | --- |
| Server-Netz | `SrvSwitch`, intern | 10.10.20.0/24 | `wazuh01`, `srv01` |
| Client-Netz | `CliSwitch`, intern | 10.10.30.0/24 | `client01` |
| Außen | `LabSwitch`, intern mit NAT | 10.10.10.0/24 | `fw01` (WAN-Seite) |

`fw01` (OPNsense) bekommt drei Netzwerkadapter und routet zwischen den Netzen. Zu klären und hier zu dokumentieren:

- Welche Firewall-Regeln erlauben nur den nötigen Verkehr (Agenten zum Server auf 1514/1515, Browser zum Dashboard auf 443)?
- Wie wird die Trennung getestet (zum Beispiel ein Zugriff, der blockiert sein muss)?
- Wie ändern sich Agentenadresse und feste IPs der VMs?

Wer zusätzlich VLAN-IDs zeigen möchte, kann sie in Hyper-V an den Netzwerkadaptern der VMs setzen. Die Umsetzung hängt vom Switch-Typ ab und wird hier nach dem Test beschrieben.

_Status: geplant, noch nicht umgesetzt._

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

_Hier eigene Beobachtungen, Probleme und Lösungen festhalten._
