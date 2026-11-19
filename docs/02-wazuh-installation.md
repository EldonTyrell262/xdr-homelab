# 2. Wazuh-Server installieren

Wazuh besteht aus drei zentralen Komponenten: Indexer (Datenhaltung), Server (Analyse und Regeln) und Dashboard (Weboberfläche). Für ein Labor laufen alle drei auf einer VM.

Quelle: [Wazuh Quickstart](https://documentation.wazuh.com/current/quickstart.html)

## Voraussetzungen

- RHEL 9 (64 Bit), feste IP 10.10.10.10, Hostname `wazuh01`
- 4 vCPU, 8 GB RAM, mindestens 50 GB Speicher (Herstellerempfehlung für bis zu 25 Agenten)

## Installation

Auf `wazuh01`:

```bash
curl -sO https://packages.wazuh.com/4.14/wazuh-install.sh && sudo bash ./wazuh-install.sh -a
```

Am Ende zeigt der Installer Benutzer (`admin`) und Passwort für das Dashboard. Das Passwort sicher notieren, **nicht** in dieses Repository schreiben.

Passwörter später erneut anzeigen:

```bash
sudo tar -O -xvf wazuh-install-files.tar wazuh-install-files/wazuh-passwords.txt
```

## Firewall öffnen

```bash
sudo firewall-cmd --permanent --add-port={443,1514,1515,55000}/tcp
sudo firewall-cmd --reload
```

## Prüfen

- Dashboard im Browser des Hosts öffnen: `https://10.10.10.10` (Zertifikatswarnung im Labor bestätigen)
- Dienste prüfen:

```bash
sudo systemctl status wazuh-manager wazuh-indexer wazuh-dashboard
```

## Notizen

_Dauer der Installation, Fehlermeldungen und Lösungen hier festhalten._
