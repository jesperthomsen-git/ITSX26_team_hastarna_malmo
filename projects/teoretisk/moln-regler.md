# Hetzner cloud configs

## D1 - D2
in tcp 22 172.20.1.2 D1 allow “SSH from lab jump host”
in tcp 22 172.20.1.10 D2 allow “SSH from course control service”
## D3
ut tcp 53 185.12.64.1 D3 allow ”DNS to Hetzner”
ut tcp 53 185.12.64.2 D3 allow ”DNS to Hetzner”
ut udp 53 185.12.64.1 D3 allow “DNS to Hetzner”
ut udp 53 185.12.64.2 D3 allow ”DNS to Hetzner”
## D4
ut udp 123 0.0.0.0 “D4 allow NTP”
## D5
ut tcp 514 172.20.1.58 “D5 allow firewall logs to log server”
## D6
ut udp 67 172.20.0.1 “D6 allow DHCP to eth1 server”
ut udp 67 10.40.4.1 “D6 allow DHCP to eth2 server”
## D7
ut tcp 443 0.0.0.0 “D7 allow package updates”  


### elev-05:  
in tcp 80 0.0.0.0/0 ”F1 allow public web porta”l
ut tcp 8080 10.40.4.20 “F2 allow portal to fetch application data”
in tcp 80 10.40.4.42 “F4 allow staff access to portal”

### elev-10:
in tcp 8080 10.40.4.10 “F2 allow portal requests”
ut tcp 5432 10.40.4.34 “F3 allow application access to database”

### elev-43:
in tcp 5432 10.40.4.20 “F3 allow database connections from application”

### elev-35:
ut tcp 80 10.40.4.10 “F4 allow staff client access to portal”  


# Molnregler – Team 4 Hästarna

## elev-10, elev-43, elev-35

Utskrift av `moln brandvägg regel lista` på jump:

| Nr | Riktning | Protokoll | Port | Adress | Beskrivning |
|---|---|---|---|---|---|
| 5 | ut | udp | 123 | 0.0.0.0/0 | D4 NTP |
| 6 | ut | tcp | 443 | 0.0.0.0/0 | D7 uppdateringar |

## elev-05 (Ludvig, webb)

Ludvig tar emot trafik från internet och behöver därför en inkommande regel utöver D4 och D7:

| Riktning | Protokoll | Port | Adress | Beskrivning |
|---|---|---|---|---|
| in | tcp | 80 | 0.0.0.0/0 | F1 publik webbportal |
| ut | udp | 123 | 0.0.0.0/0 | D4 NTP |
| ut | tcp | 443 | 0.0.0.0/0 | D7 uppdateringar |

Ludvig lägger reglerna själv från sitt eget konto på jump. Nummer och exakt utskrift kommer från hans `moln brandvägg regel lista`.

## Varför molnregler bara för D4, D7 och F1

- Molnbrandväggen filtrerar bara det publika gränssnittet. Trafik i privata nät (labbnätet och teamnätet) passerar den inte.
- D1, D2, D5, F2, F3 och F4 går i privata nät och filtreras på värden med nftables.
- D3 (DNS mot Hetzners resolvrar) och D6 (DHCP) släpper molnet alltid.
- F1 är det enda flödet som kommer utifrån, så den behöver en molnregel hos den som kör webbservern.
- Den första utgående regeln stänger all annan utgående trafik mot internet, så D4 och D7 skrevs direkt efter varandra.
- Inga inkommande regler behövs för elev-10, som saknar publik tjänst.