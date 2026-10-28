# Adressplan – Team 4 Hästarna

## Förutsättningar

- Uppdragsgivarens adressutrymme är 10.40.0.0/16 (RFC 1918, privat).
- Kursen har tilldelat Team 4 nätet 10.40.4.0/24 i molnplattformen (Hetzner Cloud). Det används för att realisera planen i labbet.
- Planen omfattar endast IPv4. IPv6 är avstängt på labbservrarna enligt kursens förutsättningar.
- Gatewayen för teamnätet är 10.40.4.1 och är reserverad av plattformen. Per subnät reserverar plattformen nät- och broadcastadress.
- Ingen rad utan uträkning. Ej allokerat utrymme får inte användas innan planen uppdaterats.

## Del A: Teamnätet 10.40.4.0/24

### Subnät

| Prefix | Syfte | Nät – broadcast | Serveradresser | Reserverat | Uträkning |
|---|---|---|---|---|---|
| 10.40.4.0/28 | Webb / DMZ | 10.40.4.0 – 10.40.4.15 | 10.40.4.2 – 10.40.4.14 | 10.40.4.1 (gateway) | 32 - 28 = 4 värdbitar, 2^4 = 16 adresser, 14 användbara. Gatewayen tar .1, så 13 serveradresser |
| 10.40.4.16/28 | Applikation | 10.40.4.16 – 10.40.4.31 | 10.40.4.17 – 10.40.4.30 | – | 32 - 28 = 4 värdbitar, 16 adresser, 14 användbara |
| 10.40.4.32/29 | Databas | 10.40.4.32 – 10.40.4.39 | 10.40.4.33 – 10.40.4.38 | – | 32 - 29 = 3 värdbitar, 2^3 = 8 adresser, 6 användbara |
| 10.40.4.40/29 | Klient | 10.40.4.40 – 10.40.4.47 | 10.40.4.41 – 10.40.4.46 | – | 32 - 29 = 3 värdbitar, 8 adresser, 6 användbara |
| 10.40.4.48 – 10.40.4.255 | Ej allokerat | – | – | Ja | 208 adresser (16 + 64 + 128). Täcks av 10.40.4.48/28, 10.40.4.64/26 och 10.40.4.128/25 |

Subnäten ligger på jämna gränser för sin storlek (/28 på 0 och 16, /29 på 32 och 40) och överlappar inte. Tillsammans med det ej allokerade utrymmet fyller de hela /24:et (16 + 16 + 8 + 8 + 208 = 256).

### Reserverade adresser

| Adress | Vad det är | Varför den inte kan ges till en server |
|---|---|---|
| 10.40.4.0 | Nätadress för teamnätet och för Webb/DMZ | Namnet på nätet |
| 10.40.4.1 | Gateway | Reserverad av plattformen |
| 10.40.4.15 | Broadcast i Webb/DMZ | Sista adressen i subnätet |
| 10.40.4.16 | Nätadress i Applikation | Namnet på subnätet |
| 10.40.4.31 | Broadcast i Applikation | Sista adressen i subnätet |
| 10.40.4.32 | Nätadress i Databas | Namnet på subnätet |
| 10.40.4.39 | Broadcast i Databas | Sista adressen i subnätet |
| 10.40.4.40 | Nätadress i Klient | Namnet på subnätet |
| 10.40.4.47 | Broadcast i Klient | Sista adressen i subnätet |
| 10.40.4.255 | Broadcast för teamnätet | Sista adressen i nätet |

### Tilldelade serveradresser

| Adress | Server | Adress i labbnätet idag | Subnät | Ansvarig | Status |
|---|---|---|---|---|---|
| 10.40.4.10 | elev-05 | 172.20.1.105 | Webb / DMZ (10.40.4.0/28) | Ludvig Alm | Aktiv |
| 10.40.4.20 | elev-10 | 172.20.1.110 | Applikation (10.40.4.16/28) | Stefan Antovic | Aktiv |
| 10.40.4.34 | elev-43 | 172.20.1.143 | Databas (10.40.4.32/29) | Jesper Thomsen | Aktiv |
| 10.40.4.42 | elev-35 | 172.20.1.135 | Klient (10.40.4.40/29) | Edvin Pihl | Aktiv |

Servrarna kopplas in med nytt nätkort (eth2). Status är Aktiv när servern är inkopplad och adressen verifierad med `ip -br addr`.

### System utanför teamnätet (labbnätet 172.20.1.0/24)

| System | Adress | Funktion |
|---|---|---|
| Jump-server | 172.20.1.2 | Administration via SSH |
| ctf-server | 172.20.1.10 | Kursens kontrolltjänst |
| Loggserver (log) | 172.20.1.58 | Central loggmottagare |
| Hetzners DNS-resolvrar | 185.12.64.1, 185.12.64.2 | Namnuppslag |

### Antaganden

- Teamet har fyra servrar, en per medlem. Webb- och applikationsnäten (/28) rymmer upp till 13 respektive 14 servrar, och databas- och klientnäten (/29) upp till 6 vardera, så det finns utrymme för tillväxt.
- Rollerna per server är bekräftade av teamet.
- Loggservern är kursens log (172.20.1.58) och ligger utanför teamnätet, så teamnätet har inget eget loggsubnät.
- Gatewayen 10.40.4.1 är kontrollerad med `moln status` och `ip route` (rutten 10.40.4.0/24 via 10.40.4.1 på eth2).