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
| 10.40.4.40/29 | Management | 10.40.4.40 – 10.40.4.47 | 10.40.4.41 – 10.40.4.46 | – | 32 - 29 = 3 värdbitar, 8 adresser, 6 användbara |
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
| 10.40.4.40 | Nätadress i Management | Namnet på subnätet |
| 10.40.4.47 | Broadcast i Management | Sista adressen i subnätet |
| 10.40.4.255 | Broadcast för teamnätet | Sista adressen i nätet |

### Tilldelade serveradresser

| Adress | Server | Adress i labbnätet idag | Subnät | Ansvarig | Status |
|---|---|---|---|---|---|
| 10.40.4.10 | elev-05 | ej dokumenterad | Webb / DMZ (10.40.4.0/28) | Ludvig Alm | Planerad |
| 10.40.4.20 | elev-10 | 172.20.1.110 | Applikation (10.40.4.16/28) | Stefan Antovic | Planerad |
| 10.40.4.34 | elev-43 | ej dokumenterad | Databas (10.40.4.32/29) | Jesper Thomsen | Planerad |
| 10.40.4.42 | elev-35 | ej dokumenterad | Klient (10.40.4.40/29) | Edvin Pihl | Planerad |

Servrarna kopplas in med nytt nätkort (eth2). Status ändras till Aktiv när servern är inkopplad och adressen verifierad med `ip -br addr`.

### System utanför teamnätet (labbnätet 172.20.1.0/24)

| System | Adress | Funktion |
|---|---|---|
| Jump-server | 172.20.1.2 | Administration via SSH |
| ctf-server | 172.20.1.10 | Kursens kontrolltjänst |
| Loggserver (log) | 172.20.1.58 | Central loggmottagare |
| Hetzners DNS-resolvrar | 185.12.64.1, 185.12.64.2 | Namnuppslag |

### Antaganden

- Teamet har fyra servrar idag, en per medlem. Webb- och applikationsnäten (/28) rymmer upp till 13 respektive 14 servrar, och databas- och managementnäten (/29) upp till 6 vardera, så det finns utrymme för tillväxt.
- Rollerna per server är förslag och ska bekräftas av teamet.
- Loggservern är kursens log (172.20.1.58) och ligger utanför teamnätet, så teamnätet har inget eget loggsubnät.
- Gatewayen 10.40.4.1 ska kontrolleras efter inkoppling med `moln status` och `ip route`.

## Del B: Designblock för uppdragsgivaren (10.40.0.0/16)

Det här är teamets logiska design för uppdragsgivarens miljö. Teamnätet 10.40.4.0/24 är kursens tilldelning för labbrealiseringen och ska inte förväxlas med designblocket 10.40.4.0/23 (Data), som numeriskt omfattar det.

### Huvudblock

| Zon-ID | Prefix | Syfte | Användbart intervall | Ansvarig | Reserverat | Uträkning |
|---|---|---|---|---|---|---|
| – | 10.40.0.0/20 | Serverinfrastruktur (samlingsblock) | 10.40.0.1 – 10.40.15.254 | Drift & System | Delvis | 32 - 20 = 12 värdbitar, 4096 adresser, 4094 användbara. Nät 10.40.0.0, broadcast 10.40.15.255. Delas i de fem delnäten nedan och tilldelas inte som ett eget nät |
| ZONE-CLIENT | 10.40.16.0/21 | Klienter och arbetsstationer | 10.40.16.1 – 10.40.23.254 | IT-Support | Nej | 32 - 21 = 11 värdbitar, 2048 adresser, 2046 användbara. Nät 10.40.16.0, broadcast 10.40.23.255 |
| ZONE-DEVTEST | 10.40.24.0/22 | Utveckling och test | 10.40.24.1 – 10.40.27.254 | Utvecklingsteam | Nej | 32 - 22 = 10 värdbitar, 1024 adresser, 1022 användbara. Nät 10.40.24.0, broadcast 10.40.27.255 |
| ZONE-LAB | 10.40.28.0/24 | Labbservrar och testriggar | 10.40.28.1 – 10.40.28.254 | Lab-ansvarig | Nej | 32 - 24 = 8 värdbitar, 256 adresser, 254 användbara. Nät 10.40.28.0, broadcast 10.40.28.255 |
| ZONE-MGMT | 10.40.29.0/24 | Management och administration | 10.40.29.1 – 10.40.29.254 | Nätverkstekniker | Nej | 32 - 24 = 8 värdbitar, 256 adresser, 254 användbara. Nät 10.40.29.0, broadcast 10.40.29.255 |
| RES-30 | 10.40.30.0/23 | Framtida expansion | 10.40.30.1 – 10.40.31.254 | Ej tilldelad | Ja | 32 - 23 = 9 värdbitar, 512 adresser, 510 användbara. Nät 10.40.30.0, broadcast 10.40.31.255 |
| RES-32 | 10.40.32.0/19 | Framtida tjänster | 10.40.32.1 – 10.40.63.254 | Arkitektur | Ja | 32 - 19 = 13 värdbitar, 8192 adresser, 8190 användbara. Nät 10.40.32.0, broadcast 10.40.63.255 |
| RES-64 | 10.40.64.0/18 | Oallokerat utrymme | 10.40.64.1 – 10.40.127.254 | Ej tilldelad | Ja | 32 - 18 = 14 värdbitar, 16384 adresser, 16382 användbara. Nät 10.40.64.0, broadcast 10.40.127.255 |
| ZONE-INT | 10.40.128.0/17 | Integrationer och partneranslutningar | 10.40.128.1 – 10.40.255.254 | Integration / Gateway | Nej | 32 - 17 = 15 värdbitar, 32768 adresser, 32766 användbara. Nät 10.40.128.0, broadcast 10.40.255.255. Delas per partner eller integration före användning |

### Delnät i produktionsblocket 10.40.0.0/20

| Zon-ID | Prefix | Syfte | Användbart intervall | Ansvarig | Reserverat | Uträkning |
|---|---|---|---|---|---|---|
| ZONE-DMZ | 10.40.0.0/23 | DMZ | 10.40.0.1 – 10.40.1.254 | Drift & System | Nej | 32 - 23 = 9 värdbitar, 512 adresser, 510 användbara. Nät 10.40.0.0, broadcast 10.40.1.255 |
| ZONE-APP | 10.40.2.0/23 | Applikation | 10.40.2.1 – 10.40.3.254 | Drift & System | Nej | 32 - 23 = 9 värdbitar, 512 adresser, 510 användbara. Nät 10.40.2.0, broadcast 10.40.3.255 |
| ZONE-DATA | 10.40.4.0/23 | Data | 10.40.4.1 – 10.40.5.254 | Drift & System | Nej | 32 - 23 = 9 värdbitar, 512 adresser, 510 användbara. Nät 10.40.4.0, broadcast 10.40.5.255 |
| ZONE-OPS | 10.40.6.0/23 | Driftstjänster | 10.40.6.1 – 10.40.7.254 | Drift & System | Nej | 32 - 23 = 9 värdbitar, 512 adresser, 510 användbara. Nät 10.40.6.0, broadcast 10.40.7.255 |
| RES-PROD | 10.40.8.0/21 | Reserv i produktionsblocket | 10.40.8.1 – 10.40.15.254 | Drift & System | Ja | 32 - 21 = 11 värdbitar, 2048 adresser, 2046 användbara. Nät 10.40.8.0, broadcast 10.40.15.255 |

### Kapacitetskontroll

- Delnäten i produktionsblocket fyller exakt 10.40.0.0/20: 4 x 512 + 2048 = 4096 adresser.
- Huvudblocken täcker hela 10.40.0.0/16 utan luckor och utan överlapp (i enheter om 256: 16 + 8 + 4 + 1 + 1 + 2 + 32 + 64 + 128 = 256).
- Blocken ligger i stigande ordning efter nätadress.
- Blockstorlekarna är grova designblock med utrymme för tillväxt. De är inte uträknade från ett antal enheter per zon.