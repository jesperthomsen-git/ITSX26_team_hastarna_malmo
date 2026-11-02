### Spårbarhetslista

| Rad-id | Riktning | Källzon / Källa | Målzon / Mål | Proto/port | Lager (moln/värd) | Motivering (verksamhetsfunktion) | Regelns identifierare | Loggar? | Status |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **F1** | IN | 10.0.10.0/24 | 10.0.20.5 | TCP/22 | Host (nftables) | - | rule-ssh-mgmt-allow | JA | Aktiv |
| **F2** | IN | 0.0.0.0/0 | 10.0.20.10 | TCP/443 | Cloud (NSG/FW) | - | secgrp-web-https-in | NEJ | Aktiv |
| **F3** | OUT | 10.0.20.0/24 | 8.8.8.8/1.1.1.1 | UDP/53 | Host (nftables) | - | rule-dns-out-allow | NEJ | Aktiv |
| **F4** | IN | 10.0.20.10 | 10.0.30.15 | TCP/5432 | Host (nftables) | - | rule-db-pg-allow | JA | Aktiv |
| **F5** | OUT | 10.0.20.0/24 | 0.0.0.0/0 | TCP/80,443 | Host/Cloud | - | rule-egress-web-allow | JA | Under granskning |
| **F6** | IN | Alla (0.0.0.0/0) | Alla (0.0.0.0/0) | ANY | Host (nftables) | - | rule-default-drop-input | JA | Aktiv (Default Drop) |
| **D4** | OUT | Lokal Host | NTP-server | UDP/123 | Host (nftables) | - | rule-ntp-out | NEJ | Aktiv |
| **D5** | OUT | Lokal host | 172.20.1.58 | TCP/5432 / 514 | Host (nftables) | - | rule-syslog-out | JA | Aktiv |
| **D6** | OUT/IN | Lokal host | DHCP-server | UDP/67,68 | Host (nftables) | - | rule-dhcp-req | NEJ | Aktiv |
| **D7** | OUT | Lokal host | Repositories | TCP/443 | Host/Cloud | - | rule-dnf-update | NEJ | Valfri / Aktiv |
| **F-01** | IN | Internet | DMZ | TCP/443 | Cloud (NSG/FW) | Kunder når den publika portalen | secgrp-portal-https-in | TBD | Ny |
| **F-02** | IN | Klienter | DMZ | TCP/443 | Host (nftables) | Personalen använder portalen | rule-portal-internal-allow | TBD | Ny |
| **F-03** | OUT | DMZ | Applikation | TCP/8080 | Host (nftables) | Portalen hämtar orderdata åt användarna | rule-app-order-allow | TBD | Ny |
| **F-04** | OUT | Applikation | Data | TCP/5432 | Host (nftables) | Appen läser och skriver kunddata | rule-app-db-allow | TBD | Ny |
| **F-05** | IN | Internet (admin) | Management (jump) | TCP/22 | Cloud (NSG/FW) | Admin loggar in på jump-servern | secgrp-jump-ssh-in | TBD | Ny |
| **F-06** | OUT | Management (jump) | Alla servrar | TCP/22 | Host (nftables) | Förvaltning och underhåll av servrarna | rule-jump-mgmt-allow | TBD | Ny |
| **F-07** | OUT | Alla servrar | Driftzonen (loggserver) | TCP/6514 | Host (nftables) | Central loggning över TLS | rule-syslog-tls-out | JA | Ny |
| **F-08** | OUT | Alla servrar | Extern DNS-server | UDP/53 | Cloud (NSG/FW) | Namnuppslag mot internet | secgrp-dns-out | TBD | Ny |
| **F-09** | OUT | Alla servrar | Extern tidskälla | UDP/123 | Cloud (NSG/FW) | Rätt tid, så att loggar/certifikat stämmer | secgrp-ntp-out | TBD | Ny |
| **F-10** | OUT | Alla servrar | Uppdateringsserver | TCP/443 | Cloud (NSG/FW) | Säkerhetsuppdateringar och patchning | secgrp-repo-update-out | TBD | Ny |
| **F-11** | OUT | Driftzonen | Hanterade system | TCP/TBD | Host (nftables) | Övervakning, backup och patchning | rule-mgmt-ops-allow | TBD | Under utredning |
| **F-12** | IN/OUT | Alla | Alla | ANY | Host/Cloud | Default Deny (allt annat nekas) | rule-default-drop-all | JA | Aktiv (Default Drop) |
