# Tidslinje – huvudfall: (fångst U8.1)  
Alla tider är UTC ur fångsten. Datum: 2026-11-18.

| Tid (UTC) | Flöde | Avviker | Paket | Loggpost | Säkerhet | Bedömning |
|---|---|---|---|---|---|---|
| 11:11:59,156 | 172.20.1.114 → 172.20.1.110, SYN mot port 613 (första i skanningen) | en källa, många olika portar, tätt | 83 | ingen | Hög | angrepp, T1046 |
| 11:12:02,777 | 172.20.1.114 → 172.20.1.110 port 22, SYN | port 22 hittad öppen under skanningen | 219 | ingen | Medel | angrepp, T1046 |
| 11:12:17,361 | 172.20.1.114:51115 → 172.20.1.110 port 22, SYN | start på lång SSH-session | 533 | | Medel | angrepp, T1078 (hypotes, bekräftad av loggposten) |
| 11:12:18,863 | (loggpost) sshd: Accepted password för student från 172.20.1.114 port 51115 | inloggning lyckades | 533 | ja, wazuh-archives, rule 5715 | Hög | stöder paket 533 |
| 11:12:22,395 | 172.20.1.110:46400 → 172.20.1.118 port 22, SYN | SSH från min server vidare till en annan maskin | 542 | ingen | Medel | angrepp, T1021 |
| 11:12:25,660 | 172.20.1.110 → 185.12.64.1, DNS TXT-fråga mot *.sync.telemetri-app.net | långt kodat namn, första i tunneln | 552 | ingen | Hög | angrepp, T1048 |
| 11:10:26 → | 172.20.1.110 → 172.20.1.58 port 1514, SYN var 5:e sekund, svar RST | jämn takt, ett enda mål | 6, 8, 10 … | ingen | Hög | felkonfiguration |  