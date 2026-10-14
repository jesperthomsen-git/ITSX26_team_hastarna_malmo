# Adressplan för 10.40.0.0/16

**Förutsättningar:**
- Uppdragsgivarens adressutrymme: `10.40.0.0/16` (RFC 1918)
- Omfattar endast IPv4 (IPv6 är avstängt på labbservrarna)
- Alla nätverk är sorterade i storleksordning för att underlätta framtida rutt-summering (supernetting).
- Ingen rad utan tillhörande uträkning.

## Tabell över Adressplan

| Prefix | Syfte | Adressintervall (första–sista) | Ansvarig tjänst | Reserverat utrymme | Kommentar / Uträkning |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `10.40.0.0/20` | Serverinfrastruktur (Produktion) | `10.40.0.1` – `10.40.15.254` | Drift & System | Nej | **Uträkning:** $32 - 20 = 12$ host-bitar. $2^{12} = 4096$ adresser ($4094$ användbara). Nätverk: `10.40.0.0`, Broadcast: `10.40.15.255`. |
| `10.40.16.0/21` | Klienter & Arbetsstationer | `10.40.16.1` – `10.40.23.254` | IT-Support | Nej | **Uträkning:** $32 - 21 = 11$ host-bitar. $2^{11} = 2048$ adresser ($2046$ användbara). Nätverk: `10.40.16.0`, Broadcast: `10.40.23.255`. |
| `10.40.24.0/22` | Utvecklings- & Testmiljö | `10.40.24.1` – `10.40.27.254` | Utvecklingsteam | Nej | **Uträkning:** $32 - 22 = 10$ host-bitar. $2^{10} = 1024$ adresser ($1022$ användbara). Nätverk: `10.40.24.0`, Broadcast: `10.40.27.255`. |
| `10.40.28.0/24` | Labbservrar & Testriggar | `10.40.28.1` – `10.40.28.254` | Lab-ansvarig | Nej | **Uträkning:** $32 - 24 = 8$ host-bitar. $2^8 = 256$ adresser ($254$ användbara). Nätverk: `10.40.28.0`, Broadcast: `10.40.28.255`. |
| `10.40.29.0/24` | Management & Out-of-Band | `10.40.29.1` – `10.40.29.254` | Nätverkstekniker | Nej | **Uträkning:** $32 - 24 = 8$ host-bitar. $2^8 = 256$ adresser ($254$ användbara). Nätverk: `10.40.29.0`, Broadcast: `10.40.29.255`. |
| `10.40.30.0/23` | Framtida expansion / Reserverat | `10.40.30.1` – `10.40.31.254` | Ej tilldelad | **Ja** (Reserverat) | **Uträkning:** $32 - 23 = 9$ host-bitar. $2^9 = 512$ adresser ($510$ användbara). Nätverk: `10.40.30.0`, Broadcast: `10.40.31.255`. |
| `10.40.32.0/19` | Stort reserverat utrymme för framtida tjänster | `10.40.32.1` – `10.40.63.254` | Arkitektur | **Ja** (Reserverat) | **Uträkning:** $32 - 19 = 13$ host-bitar. $2^{13} = 8192$ adresser ($8190$ användbara). Nätverk: `10.40.32.0`, Broadcast: `10.40.63.255`. |
| `10.40.64.0/18` | Öppet / Oallokerat adressutrymme | `10.40.64.1` – `10.40.127.254` | Ej tilldelad | **Ja** (Reserverat) | **Uträkning:** $32 - 18 = 14$ host-bitar. $2^{14} = 16384$ adresser ($16382$ användbara). Nätverk: `10.40.64.0`, Broadcast: `10.40.127.255`. |
| `10.40.128.0/17` | Externt / Integrationszon | `10.40.128.1` – `10.40.255.254` | Integration / Gateway | Nej | **Uträkning:** $32 - 17 = 15$ host-bitar. $2^{15} = 32768$ adresser ($32766$ användbara). Nätverk: `10.40.128.0`, Broadcast: `10.40.255.255`. |

---
## Sammanfattning av utrymmet
Genom att dela in nätverken i block som följer 2-potenser och är sorterade i ordning kan ovanstående struktur enkelt sammanfattas eller expanderas i framtiden utan fragmentering av IP-adresser.
# Adressplan

**Förutsättningar:** Uppdragsgivarens adressutrymme är 10.40.0.0/16. Planen omfattar IPv4. IPv6 är avstängt på labbservrarna och ingår inte i planen.

| Prefix | Syfte | Adressintervall (första–sista) | Ansvarig tjänst | Reserverat utrymme | Kommentar och uträkning |
|---|---|---|---|---|---|
