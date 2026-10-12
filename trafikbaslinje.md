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