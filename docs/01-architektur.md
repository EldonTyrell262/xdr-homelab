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
