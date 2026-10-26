# Trafikbaslinje

**Status: rapporterade observationer från gruppens tidigare analys.** Paketfångsterna har inte granskats direkt i denna revidering. Observation är inte samma sak som godkännande av ett framtida flöde.

## Fångstunderlag och källgräns

Underlaget hänvisar till `baslinje.pcap` och `U1.4-avvikelsen.pcap`. Start/slut för hela fångsterna och fångstpunkt finns inte i den text som skickats in och kan inte rekonstrueras ur den. Därför redovisas inte någon påhittad mätperiod eller fångstpunkt.

För `baslinje.pcap` anges tidsreferensen `2026-10-12T08:33:38Z` och en `who`-uppgift om inloggning 08:30 från `172.20.1.2`. Tidszonen för `who`-uppgiften anges inte i källtexten. `U1.4-avvikelsen.pcap` används som underlag för de rapporterade DNS-, HTTP-, NTP- och korta SSH-anslutningarna. Att filnamnet innehåller ”avvikelsen” räcker inte för att slå fast att trafiken är normaldrift.

## Rapporterade flöden

Riktning anges som vem som initierar kommunikationen. Svar hör till samma utbyte; detta innebär inte fri rätt för mottagaren att starta nya anslutningar.

| ID | Källa | Mål | Protokoll/port | Riktning | Frekvens och syfte | Lager | Rapporterat belägg |
|---|---|---|---|---|---|---|---|
| B1 | `172.20.1.2` | `172.20.1.110` (Elev 10) | TCP, destinationsport 22; SSH enligt gruppens analys | Initieras av `172.20.1.2`, med svar tillbaka | Pågående session under fångsten enligt tidigare analys. Små paket uppges ha storleken 36 byte; vad storleksmåttet avser behöver preciseras. Administration stöds av rapporterad inloggningsuppgift men exakt användning är inte verifierad. | SSH på applikationslagret över TCP på transportlagret | `baslinje.pcap`; `tcpdump -nn -r baslinje.pcap`; `who` med inloggning 08:30 från `172.20.1.2`. Komplettera med paket- och loggreferenser. |
| B2 | `172.20.1.110` | `185.12.64.1` | UDP, destinationsport 53; DNS enligt gruppens analys | Initieras av `172.20.1.110`, med svar tillbaka | 15 frågor, ungefär var 40:e sekund enligt analysen. Namnuppslagning; efterfrågade namn och bakomliggande funktion är inte angivna. | DNS över UDP | `U1.4-avvikelsen.pcap`; Statistics → Conversations → UDP. Komplettera med DNS-frågor och paketnummer. |
| B3 | `172.20.1.110` | `46.224.108.117` | TCP, destinationsport 80; HTTP enligt gruppens analys | Initieras av `172.20.1.110`, med svar tillbaka | 15 korta anslutningar, ungefär var 40:e sekund och efter DNS-frågorna enligt analysen. Svar uppges innehålla JSON. Återkommande hämtning är en hypotes; funktion och koppling till DNS behöver verifieras. | HTTP över TCP | `U1.4-avvikelsen.pcap`; filter `http`; Conversations → TCP. Komplettera med begäran, svar och paketnummer. |
| B4 | `172.20.1.110` | `185.12.64.2` | UDP, destinationsport 123; NTP enligt gruppens analys | Initieras av `172.20.1.110`, med svar tillbaka | 7 förfrågningar, ungefär var 110:e sekund enligt analysen. Trolig tidssynkronisering; vald tidskälla behöver bekräftas. | NTP över UDP | `U1.4-avvikelsen.pcap`; Statistics → Conversations → UDP. Komplettera med NTP-paket och systemets tidskonfiguration. |
| B5 | `172.20.1.2` | `172.20.1.110` | TCP, destinationsport 22; SSH enligt gruppens analys | Initieras av `172.20.1.2`, med svar tillbaka | 2 korta anslutningar med 10 paket vardera enligt analysen. Lyckad inloggning och administrativ användning är inte verifierade för dessa anslutningar. | SSH över TCP | `U1.4-avvikelsen.pcap`; Statistics → Conversations → TCP. Komplettera med autentiseringslogg. |

## Tolkning och fortsatt användning

- B1 och B5 avser olika fångster och behålls därför separat.
- Protokollbenämningarna kommer från gruppens analys. Portnummer ensamt bevisar inte applikationsprotokoll eller användningssyfte.
- Uppgivna antal och intervall behöver kontrolleras mot fångsternas längd och avgränsning. Inga ytterligare flöden eller saknade tjänster kan uteslutas med detta underlag.
- HTTP-flödet ska utredas innan det godkänns. Utred om funktionen behövs och om HTTPS eller annat lämpligt skydd kan användas. Ändra inte observationen till TCP 443; ett sådant byte är ett separat designbeslut.
- Interna DNS-/NTP-mål och villkorade externa mål är föreslagna i adressplanen och flödestabellen nedan. De är inte verifierade eller godkända genom observationerna; externa regler får öppnas först efter kontroll av målens lämplighet och godkännande.

## Föreslagen rollmappning till adressplanen

Denna tabell är design, inte observation. Ursprungliga IP-adresser behålls i flödesbevisen ovan.

| Observerad adress | Rapporterad funktion | Föreslagen roll och adress | Beslut i förslaget |
|---|---|---|---|
| `172.20.1.2` | Initierar SSH mot Elev 10 | ADMIN01, management `10.40.29.10` | Administration går via JUMP01 `10.40.29.20`, inte direkt till labbservern. |
| `172.20.1.110` | Elev 10/labbserver i gruppens beskrivning | LAB01, labb `10.40.28.110` | Isoleras från produktion och använder gemensam DNS och tid. |
| `185.12.64.1` | Rapporterat DNS-mål | Extern resolver för DNS01 | Endast DNS01 tillåts använda detta mål om målvalet kan verifieras vid införande. |
| `185.12.64.2` | Rapporterat NTP-mål | Extern tidskälla för NTP01 | Endast NTP01 tillåts använda detta mål om målvalet kan verifieras vid införande. |
| `46.224.108.117` | Rapporterat HTTP-mål | Ingen tillåten roll i målbilden | TCP 80 nekas. Ingen antagen tjänst på TCP 443 införs. |

De ytterligare web-/applikations-/databasflödena i flödestabellen i `trafikbaslinje.md` konkretiserar den befintliga zonidén. De har inte observerats i paketfångsterna. PostgreSQL på port 5432 är ett föreslaget tjänsteval, inte en uppgift ur baslinjen.


## Workshop 2 – föreslagna flöden

**Status: designförslag, inte observerad trafik.** System, tjänster och regler i detta avsnitt är föreslagna för målmiljön och kräver kontroll, godkännande och test före införande.

Tabellen är den konkreta målbilden för den nya miljön, inte en omskrivning av paketfångsterna. Port betyder destinationsport. Varje rad beskriver initiatorn; svar hanteras tillståndsbaserat eller med motsvarande begränsad returkontroll. En rad ger inte mottagaren rätt att initiera nya anslutningar tillbaka.

### Målgrupper

- **Servergrupp S:** WEB01, APP01, DB01, LOG01, ID01, POLICY01, STATUS01, BACKUP01, PATCH01, DNS01, NTP01 och LAB01. Adresser finns i adressplanens systemtabell.
- **Enhetsgrupp K:** CLIENT01 `10.40.16.10`, ADMIN01 `10.40.29.10` och JUMP01 `10.40.29.20`.
- S och K är uttryckliga listor, inte hela subnät. Reglerna delas upp per listad källa och destination i konfigurationen. Identitet och resursbehörighet kontrolleras dessutom i tjänsten.
- FW-Y:s managementadress är `10.40.29.2`; FW-Z:s är `10.40.29.1`. Inga administrationsgränssnitt publiceras mot internet.
- Skrivningen ”utom sig själv” innebär lokal funktion på servern, inte krav på att gå ut genom zonbrandväggen till den egna adressen.

### Föreslagna tillåtna flöden

| Rad | Källzon | Målzon | Protokoll | Port | Riktning | Motivering (varför denna funktion?) | Filtreras var? |
|---:|---|---|---|---|---|---|---|
| 1 | Internet | DMZ: WEB01 `10.40.0.10` | TCP / HTTPS | 443 | Internetklient → WEB01 | Publicerat webbinnehåll. Skyddade interna funktioner kräver separat verifierad åtkomst. | FW-Y och WEB01:s värdfilter; proxy begränsar publicerade URL:er. |
| 2 | DMZ: WEB01 `10.40.0.10` | Applikation: APP01 `10.40.2.10` | TCP / HTTPS med mTLS | 443 | WEB01 → APP01 | Backend för publicerad webbfunktion. APP01 skiljer offentlig funktion från behörighetskrävande funktion. | FW-Z, APP01:s värdfilter, mTLS och applikationsbehörigheter. |
| 3 | Klienter: CLIENT01 `10.40.16.10` | Applikation: APP01 `10.40.2.10` | TCP / HTTPS | 443 | CLIENT01 → APP01 | Godkänd användarfunktion efter identitets-, roll- och enhetskontroll. | FW-Z, APP01:s värdfilter och applikationens åtkomstkontroll via POLICY01. |
| 4 | Applikation: APP01 `10.40.2.10` | Data: DB01 `10.40.4.10` | TCP / PostgreSQL med TLS | 5432 | APP01 → DB01 | Läsning/skrivning i applikationens egen databas med begränsat tjänstekonto. | FW-Z, DB01:s värdfilter och databasens TLS-/konto-/behörighetsregler. |
| 5 | Management: ADMIN01 `10.40.29.10` | Management: JUMP01 `10.40.29.20` | TCP / SSH | 22 | ADMIN01 → JUMP01 | Administration via personligt konto, MFA, godkänd enhet och sessionsloggning. | JUMP01:s värdfilter och autentisering/åtkomstkontroll. Samma subnät: FW-Z är inte enda kontroll. |
| 6 | Management: JUMP01 `10.40.29.20` | Hanterade servrar: servergruppen S nedan | TCP / SSH | 22 | JUMP01 → varje uttryckligt servermål i S | Rollbegränsad administration. Separat målregel per värd, inget generellt sudo-konto. | FW-Z där zoner skiljer sig; varje måls värdfilter och SSH-behörighet. |
| 7 | Management: JUMP01 `10.40.29.20` | Management: FW-Y `10.40.29.2`, FW-Z `10.40.29.1` | TCP / HTTPS | 443 | JUMP01 → brandväggarnas administrationsgränssnitt | Administration av nätregler med personliga konton och loggade ändringar. | Brandväggarnas lokala managementregler och administrationsbehörigheter. |
| 8 | CLIENT01 i klientzonen; ADMIN01/JUMP01 i management | Drift: ID01 `10.40.6.20` | TCP / HTTPS | 443 | Angiven klient/gateway → ID01 | Inloggning/MFA och identitetskontroll för skyddad åtkomst. | FW-Z, ID01:s värdfilter och identitetstjänstens klient-/rollregler. |
| 9 | WEB01 i DMZ; APP01 i applikation; JUMP01 i management | Drift: POLICY01 `10.40.6.21` | TCP / HTTPS med tjänsteautentisering | 443 | Åtkomstkontroll → POLICY01 | Hämta åtkomstbeslut och ompröva aktiva skyddade sessioner. | FW-Z, POLICY01:s värdfilter och autentiserade klientidentiteter. |
| 10 | Drift: POLICY01 `10.40.6.21` | Drift: ID01 `10.40.6.20`, STATUS01 `10.40.6.22` | TCP / HTTPS med tjänsteautentisering | 443 | POLICY01 → respektive beslutsdatakälla | Kontrollera kontostatus, roller och aktuell enhetsstatus. | Värdfilter på ID01/STATUS01 samt deras API-behörigheter; samma zon. |
| 11 | Servergrupp S och enhetsgrupp K, utom STATUS01 självt | Drift: STATUS01 `10.40.6.22` | TCP / HTTPS med enhetsautentisering | 443 | Hanterad enhet → STATUS01 | Rapportera säkerhetsstatus minst var femte minut. STATUS01 kontrollerar sin egen status lokalt. | FW-Z där zoner skiljer sig; STATUS01:s värdfilter och enhetsidentiteter. |
| 12 | Servergrupp S och enhetsgrupp K, utom LOG01 självt; FW-Y och FW-Z | Drift: LOG01 `10.40.6.10` | TCP / syslog över TLS | 6514 | Loggproducerande system → LOG01 | Central loggning av åtkomst, drift och regeländringar. LOG01 lagrar även sina egna loggar lokalt. | FW-Z där zoner skiljer sig; LOG01:s värdfilter och autentisering av loggavsändare. |
| 13 | WEB01 i DMZ; APP01 i applikation; DB01 i data; LAB01 i labb | Drift: BACKUP01 `10.40.6.30` | TCP / SFTP | 22 | Systemets backupjobb → BACKUP01 | Säkerhetskopiering med separata konton, egna kataloger och utan shellåtkomst. DB01 skickar konsistent databasexport. | FW-Z, BACKUP01:s värdfilter och begränsade SFTP-konton. |
| 14 | Servergrupp S och enhetsgrupp K, utom PATCH01 självt | Drift: PATCH01 `10.40.6.40` | TCP / HTTPS | 443 | Hanterat system → PATCH01 | Hämta administrativt införda, granskade uppdateringspaket. PATCH01 uppdateras genom samma granskade administrativa införanderutin. | FW-Z där zoner skiljer sig; PATCH01:s värdfilter och klientbehörigheter. |
| 15 | Servergrupp S och enhetsgrupp K, utom DNS01 självt | Drift: DNS01 `10.40.6.53` | UDP / DNS | 53 | Hanterat system → DNS01 | DNS-frågor till organisationens valda resolver; DNS01 använder sin lokala resolver. | FW-Z där zoner skiljer sig; DNS01:s värdfilter och resolverns klientbegränsning. |
| 16 | Servergrupp S och enhetsgrupp K, utom DNS01 självt | Drift: DNS01 `10.40.6.53` | TCP / DNS | 53 | Hanterat system → DNS01 | Stöd för DNS-svar som behöver TCP. Zonöverföring tillåts inte genom denna klientregel. | FW-Z där zoner skiljer sig; DNS01:s värdfilter och DNS-tjänstens klient-/zonöverföringsregler. |
| 17 | Drift: DNS01 `10.40.6.53` | Externt: `185.12.64.1` | UDP / DNS | 53 | DNS01 → extern DNS | Föreslagen vidarebefordran baserad på observerat DNS-mål. Regeln öppnas endast om destinationen verifieras som lämplig vid införande. | DNS01:s värdfilter, FW-Z och FW-Y; endast angivet mål. |
| 18 | Drift: DNS01 `10.40.6.53` | Externt: `185.12.64.1` | TCP / DNS | 53 | DNS01 → extern DNS | TCP-stöd för vidarebefordran. Samma villkor om verifierad destination som föregående rad. | DNS01:s värdfilter, FW-Z och FW-Y; endast angivet mål. |
| 19 | Servergrupp S och enhetsgrupp K, utom NTP01 självt | Drift: NTP01 `10.40.6.123` | UDP / NTP | 123 | Hanterat system → NTP01 | Gemensam tid för loggar och autentisering. | FW-Z där zoner skiljer sig; NTP01:s värdfilter och NTP-tjänstens klientbegränsning. |
| 20 | Drift: NTP01 `10.40.6.123` | Externt: `185.12.64.2` | UDP / NTP | 123 | NTP01 → extern tidskälla | Föreslagen tidssynkronisering till tidigare observerat mål. Regeln öppnas endast om källans lämplighet verifieras vid införande. | NTP01:s värdfilter, FW-Z och FW-Y; endast angivet mål. |

### Spårning till den ursprungliga trafikbaslinjen

| Ursprunglig observation | Hantering i målbilden | Skäl |
|---|---|---|
| SSH `172.20.1.2` → `172.20.1.110:22` i två fångster | ADMIN01→JUMP01→LAB01, TCP 22. | Föreslagen rollmappning från administration till labbserver. Ett nytt mellansteg införs för begränsning och loggning. |
| DNS `172.20.1.110` → `185.12.64.1:53/UDP` | LAB01→DNS01; endast DNS01 använder den valda externa resolvern. | Central kontroll och färre direkta externa anslutningar. TCP-stöd är ett separat designval, inte en observerad baslinjeuppgift. |
| HTTP `172.20.1.110` → `46.224.108.117:80/TCP` | Nekas. Ingen tillåtande regel för mål/port eller antagen HTTPS-ersättning. | Funktionen är inte verifierad och vanlig HTTP ger inte önskat kommunikationsskydd. |
| NTP `172.20.1.110` → `185.12.64.2:123/UDP` | LAB01→NTP01; endast NTP01 använder den valda externa tidskällan. | Samlad tidsstyrning. Ursprunglig observation behålls oförändrad i baslinjen. |

### Nekad trafik och avgränsningar

All annan trafik nekas och relevanta nekanden loggas. Det omfattar direkt klient-/DMZ-/labbåtkomst till databasen, direkt klient-/servertrafik till externa DNS-/NTP-mål, utveckling/test→produktion, integrationsflöden samt all trafik från reserverade block. Inte heller utgående internettrafik på TCP 443 är generellt tillåten.

Ingen separat övervakningsport öppnas: statusrapportering till STATUS01 och loggning till LOG01 används i denna målbild för grundläggande uppföljning. Ytterligare övervakning eller automatisk extern pakethämtning kräver ett nytt funktionsbeslut och egna regler.

### Ansvar och införande

Nätverkstekniker ansvarar för FW-Y/FW-Z och nätregler. Drift & System ansvarar för värdfilter, loggning, backup och uppdateringsdistribution. Identitetsansvarig ansvarar för ID01/POLICY01; IT-Support för status på klienter och administratörsenhet; applikations-/databasansvarig för resursbehörigheter. Tjänsteägaren bekräftar behovet och Drift & System godkänner införandet.

Varje vald regel testas med ett tillåtet och ett nekat fall, loggas och granskas 30 dagar efter införande samt efter väsentlig ändring. DNS/NTP:s begränsade kommunikationsskydd redovisas i `tillitsregler.md`, inklusive den inarbetade checklistan.
