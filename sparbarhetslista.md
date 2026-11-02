### Mall: spårbarhetslista

| Rad-id | Riktning | Källa | Mål | Proto/port | Lager (moln/värd) | Regelns identifierare | Loggar? | Status |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| F1 | IN | 10.0.10.0/24 | 10.0.20.5 | TCP/22 | Host (nftables) | rule-ssh-mgmt-allow | JA | Aktiv |
| F2 | IN | 0.0.0.0/0 | 10.0.20.10 | TCP/443 | Cloud (NSG/FW) | secgrp-web-https-in | NEJ | Aktiv |
| F3 | OUT | 10.0.20.0/24 | 8.8.8.8/1.1.1.1 | UDP/53 | Host (nftables) | rule-dns-out-allow | NEJ | Aktiv |
| F4 | IN | 10.0.20.10 | 10.0.30.15 | TCP/5432 | Host (nftables) | rule-db-pg-allow | JA | Aktiv |
| F5 | OUT | 10.0.20.0/24 | 0.0.0.0/0 | TCP/80,443 | Host/Cloud | rule-egress-web-allow | JA | Under granskning |
| F6 | IN | Alla (0.0.0.0/0) | Alla (0.0.0.0/0) | ANY | Host (nftables) | rule-default-drop-input | JA | Aktiv (Default Drop) |

