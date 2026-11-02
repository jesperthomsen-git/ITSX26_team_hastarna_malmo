# Hur vi vet vad som är normal trafik
## Baslinjen fastställs genom systematisk analys av insamlade fångstfiler (PCAP) från nätverksgränssnittet under ett definierat tidsfönster. Detta görs genom att använda verktyg som 'tcpdump, tshark och Wireshark' för att inspektera protokollbeteenden, anslutningsfrekvenser och portanvändning under standarddrift.

# Flöde för flöde

# DNS
## Källa & Mål
Klient WSL2/internt nät till lokal DNS-resolver/Gateway

## Protokoll & Port
UDP/TCP, Port 53

## Riktning
Utgående (förfrågan) och inkommande (svar)

## Frekvens & Syfte
Förekommer periodiskt vid namnuppslagning (t.ex. vid start av tjänster eller externa anrop)

## TCP/IP-lager
Applikationslagret (lager 4 i TCP/IP-modellen).

## Belägg
# Trafikbaslinje


| Källa | Mål | Protokoll/port | Riktning | Frekvens och syfte | Lager | Belägg |
|---|---|---|---|---|---|---|
| 172.20.1.2 | 172.20.1.110 (Elev 10) | TCP 22 (SSH) | Inkommande, med svar tillbaka | Pågående interaktiv session under hela fångsten, små paket på 36 byte, används för administration | Applikation (SSH) över Transport (TCP) | "tcpdump -nn -r baslinje.pcap", "who" (inloggad 08:30 från 172.20.1.2), fångad 2026-10-12T08:33:38Z |  
| 172.20.1.110 (Elev 10) | 185.12.64.1 | UDP 53 (DNS) | Utgående, med svar tillbaka | 15 frågor under fångsten, ungefär var 40:e sekund. Servern slår upp ett namn. | Applikation (DNS) över Transport (UDP) | "U1.4-avvikelsen.pcap", Statistics → Conversations → UDP |   
| 172.20.1.110 (Elev 10) | 46.224.108.117 | TCP 80 (HTTP) | Utgående, med svar | 15 korta anslutningar, ungefär var 40:e sekund, strax efter varje DNS-fråga. Svaret är JSON. Troligen en återkommande hämtning (ej verifierat). | Applikation (HTTP) över Transport (TCP) | "U1.4-avvikelsen.pcap", filter "http", Conversations → TCP |   
| 172.20.1.110 (Elev 10) | 185.12.64.2 | UDP 123 (NTP) | Utgående, med svar | 7 förfrågningar under hela fångsten, ungefär var 110:e sekund. Tidssynkronisering. | Applikation (NTP) över Transport (UDP) | "U1.4-avvikelsen.pcap", Statistics → Conversations → UDP |  
| 172.20.1.2 | 172.20.1.110 (Elev 10) | TCP 22 (SSH) | Inkommande, med svar | 2 korta sessioner med 10 paket var. Administration. | Applikation (SSH) över Transport (TCP) | "U1.4-avvikelsen.pcap", Statistics → Conversations → TCP |  
