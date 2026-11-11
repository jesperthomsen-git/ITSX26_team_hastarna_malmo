# Spårbarhetslista – elev-35, Team 4 Hästarna

Server: elev-35
Labbadress: 172.20.1.135
Teamadress: 10.40.4.42

Status "Införd" betyder att regeln har visats i det aktiva regelverket.
Det betyder inte att varje flöde har funktionstestats separat.

| Rad-id | Riktning | Källa | Mål | Protokoll/port | Lager | Regelidentifierare | Loggar? | Status |
|---|---|---|---|---|---|---|---|---|
| D1 | In | Jump 172.20.1.2 | elev-35 | TCP/22 | Värd | D1 SSH fran jump | Nej | SSH via jump har fungerat |
| D2 | In | CTF 172.20.1.10 | elev-35 | TCP/22 | Värd | D2 SSH fran ctf | Nej | Införd |
| D3 | Ut | elev-35 | 185.12.64.1 och 185.12.64.2 | UDP/53 och TCP/53 | Värd; molnets DNS-undantag | D3 DNS UDP och D3 DNS TCP | Nej | Införd |
| D4 | Ut | elev-35 | Alla adresser | UDP/123 | Värd och moln | D4 NTP | Nej | Införd i båda lagren |
| D5 | Ut | elev-35 | Loggserver 172.20.1.58 | TCP/514 | Värd | D5 Loggserver | Nej, regeln tillåter loggtransport | Införd |
| D6 | Ut | elev-35, UDP-källport 68 | Alla adresser, UDP-målport 67 | UDP 68 → 67 | Värd; molnets DHCP-undantag | D6 DHCP | Nej | Införd |
| D7 | Ut | elev-35 | Alla adresser | TCP/443 | Värd och moln | D7 Paketuppdateringar | Nej | Införd i båda lagren |
| N1 | In och ut | Övrig trafik | elev-35 respektive övriga mål | Alla som inte tillåts tidigare | Värd och moln | policy drop i in/ut; molnets implicita neka | På värden: ZON-IN-DROP och ZON-UT-DROP, begränsat till 10/minut | Default deny visat på värden |

Svarstrafik tillåts genom ct state established,related accept i båda kedjorna.
Loggreglerna ligger sist i respektive kedja på värden.
Molnbrandväggen filtrerar inte trafiken i privata nät.
