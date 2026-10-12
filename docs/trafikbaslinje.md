# Trafikbaslinje 


| Källa | Mål | Protokoll/port | Riktning | Frekvens och syfte | Lager | Belägg |
|---|---|---|---|---|---|---|
| 172.20.1.2 | 172.20.1.110 | TCP 22 (SSH) | Inkommande, med svar tillbaka | Pågående interaktiv session under hela fångsten, små paket på 36 byte, används för administration | Applikation (SSH) över Transport (TCP) | "tcpdump -nn -r baslinje.pcap", "who" (inloggad 08:30 från 172.20.1.2), fångad 2026-10-12T08:33:38Z |  