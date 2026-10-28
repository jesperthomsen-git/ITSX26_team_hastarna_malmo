# Flödestabell – Team 4 Hästarna

Det här är specifikationen som regelverket byggs efter i vecka 4. Varje rad är ett flöde. Svarstrafik hör till samma anslutning och släpps av `ct state established,related accept` i båda kedjorna. Allt som inte står i tabellen nekas, inkommande och utgående, i båda lagren.

Teamnätet är 10.40.4.0/24 med gatewayen 10.40.4.1. Servrarna är elev-35 (webb, 10.40.4.10), elev-10 (app, 10.40.4.20), elev-05 (databas, 10.40.4.34) och elev-43 (management, 10.40.4.42).

| Rad | Källzon | Målzon | Protokoll | Port | Riktning | Motivering | Filtreras var |
|---|---|---|---|---|---|---|---|
| D1 | Labbnät: jump 172.20.1.2 | Alla teamservrar (eth1) | tcp | 22 | in på varje server | Administration via jump | Värd, kedjan in. Labbnätet är privat, så molnet ser inte trafiken |
| D2 | Labbnät: ctf 172.20.1.10 | Alla teamservrar (eth1) | tcp | 22 | in på varje server | Kursens kontrolltjänst | Värd, kedjan in |
| D3 | Alla teamservrar | Hetzners DNS 185.12.64.1 och 185.12.64.2 | tcp och udp | 53 | ut på varje server | Namnuppslag | Värd, kedjan ut. Molnet släpper alltid trafiken, så ingen molnregel behövs |
| D4 | Alla teamservrar | Internet (NTP-server) | udp | 123 | ut på varje server | Tidssynk med chrony | Båda: värd i kedjan ut, och en molnregel ut |
| D5 | Alla teamservrar | Labbnät: log 172.20.1.58 | tcp | 514 | ut på varje server | Brandväggsloggen till loggservern | Värd, kedjan ut |
| D6 | Alla teamservrar | DHCP-servern (172.20.0.1 på eth1, 10.40.4.1 på eth2) | udp | 68 till 67 | ut på varje server | Förnya serverns adresser | Värd, kedjan ut. Molnet släpper alltid trafiken |
| D7 | Alla teamservrar | Internet | tcp | 443 | ut på varje server | Paketuppdateringar med dnf | Båda: värd i kedjan ut, och en molnregel ut |
| F1 | Internet | Webb/DMZ: elev-35 (10.40.4.10) | tcp | 80 | in på elev-35 | Publik webbportal (Apache) | Båda: molnregel in, och värd i kedjan in |
| F2 | Webb/DMZ: elev-35 | Applikation: elev-10 (10.40.4.20) | tcp | 8080 | ut på elev-35, in på elev-10 | Portalen hämtar orderdata | Värd i båda ändar. Teamnätet är privat |
| F3 | Applikation: elev-10 | Databas: elev-05 (10.40.4.34) | tcp | 5432 | ut på elev-10, in på elev-05 | Appen läser och skriver kunddata | Värd i båda ändar |
| F4 | Management: elev-43 (10.40.4.42) | elev-35, elev-10 och elev-05 | tcp | 22 | ut på elev-43, in på målen | Förvaltning i teamnätet | Värd i båda ändar |
| N1 | Allt annat | Allt annat | alla | alla | in och ut | Allt som inte står ovan nekas | Båda: molnet nekar inkommande som standard och allt utgående utom raderna ovan. Värden har policy drop i kedjorna in och ut |

## Beslut om flöden från trafikbaslinjen

| Flöde | Beslut | Varför |
|---|---|---|
| HTTP tcp/80 mot 46.224.108.117 var 40:e sekund | Nekas av N1 | Okänt syfte och okrypterad trafik. Tillåts först när syfte och ägare är utredda |
| tcp/4444 mot 203.0.113.104 | Nekas av N1, och loggen larmas | Ovanlig port och en enda utgående anslutning utan motivering |

