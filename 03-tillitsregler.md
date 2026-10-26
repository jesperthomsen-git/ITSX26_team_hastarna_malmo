# Tillitsregler för nätverket

**Dokumentstatus:** komplett designförslag utifrån gruppens adressplan, tillitsregler och rapporterade trafikbaslinje. Föreslagna adresser, komponenter och tjänsteval är designbeslut i detta underlag, inte observationer av den befintliga miljön. Konfigurationer och tester har inte genomförts här.

## Grundregler

1. Neka som standard mellan zoner, inom värdarnas brandväggar och ut mot internet. Endast flöden i avsnittet ”Workshop 2 – föreslagna flöden” i `trafikbaslinje.md` öppnas efter kontroll och godkännande.
2. En IP-adress eller zon ger inte tillit. Kontrollera användar-/tjänsteidentitet och resursbehörighet där åtkomsten sker.
3. Begränsa till namngivna system, destinationsport, funktion och initieringsriktning. Returtrafik hör till tillåtet utbyte; den ger inte rätt att initiera nya anslutningar tillbaka.
4. Logga tillåtna och nekade åtkomstbeslut, administrativa sessioner och regeländringar på LOG01.
5. Varje regel har ansvarig funktion enligt flödestabellen. Nätverkstekniker verkställer nätregler; tjänsteägaren bekräftar behov; Drift & System godkänner införandet. Ingen signering påstås ha skett genom detta dokument.
6. Föreslaget granskningsintervall är 30 dagar efter införandet och efter varje väsentlig förändring. Undantag löper högst sju dagar och kräver syfte, ägare och slutdatum. Inga aktiva undantag ingår i förslaget.

## Åtkomst, enhetsstatus och omprövning

| Kontroll | Konkret krav i förslaget | Verkställs av | Ansvarig funktion |
|---|---|---|---|
| Användaridentitet | Personliga konton i ID01. MFA för administration och åtkomst till verksamhetsapplikationen. Publik webbingång får endast visa avsiktligt offentligt innehåll före inloggning. | ID01, WEB01/APP01 och JUMP01 | Identitetsansvarig |
| Tjänsteidentitet | Separat identitet per tjänst. WEB01–APP01 använder mTLS. APP01–DB01 använder TLS med serververifiering och separat databaskonto med minsta rättigheter. | WEB01, APP01, DB01 | Applikations- och databasansvarig |
| Enhetsstatus | Hanterade enheter rapporterar minst var femte minut till STATUS01 med enhetsautentisering. Krav: hanterad enhet, aktivt skydd, ingen rapporterad kritisk brist och senaste godkända säkerhetsuppdateringar. En status äldre än tio minuter godtas inte för ny verksamhetsåtkomst eller administration. | STATUS01 som datakälla; POLICY01 ger beslut till åtkomstkontrollerna | IT-Support och identitetsansvarig |
| Minsta behörighet | CLIENT01 får använda applikationen, inte databasen. APP01:s databaskonto får endast nödvändiga operationer i applikationens egen databas. Administratörer får rollbegränsad åtkomst via JUMP01. | APP01, DB01, JUMP01 och FW-Z | Tjänsteägare och nätverkstekniker |
| Omprövning | Kontroll före ny resursåtkomst och minst var femte minut under skyddad session. Spärrat konto, återkallad roll eller underkänd/för gammal enhetsstatus ska återkalla åtkomst inom fem minuter från det att kontrollfunktionen registrerat ändringen. | POLICY01, WEB01/APP01 och JUMP01; tjänsteansvariga måste integrera sessionsavslut | Identitetsansvarig |
| Avbrott i kontrollfunktion | Nya skyddade sessioner nekas när beslut saknas. Befintlig åtkomst upphör senast när senaste godkända beslut blir fem minuter gammalt. Begränsade DNS-, tids-, logg- och statusflöden får fortsätta enligt egna regler för återhämtning. | Åtkomstkontroller och FW-Z | Drift & System |
| Loggning | TLS-skyddad överföring till LOG01. Daglig granskning av säkerhetslarm och månatlig regelgranskning. Föreslagen lagringstid är 30 dagar; inga lösenord eller tokens ska loggas. | LOG01 och respektive loggproducerande system | Drift & System |

Intervallen ovan är föreslagna värden för denna design och inte tidskrav hämtade ur NIST. Teknisk integration och funktion måste testas före införande.

## Zonregler

| Zon | Adressblock | Tillitsregel |
|---|---|---|
| DMZ | `10.40.0.0/23` | Internet når endast WEB01 på TCP 443. WEB01 når APP01 på TCP 443 med mTLS samt sina särskilt angivna stödtjänster. |
| Applikation | `10.40.2.0/23` | APP01 tar emot HTTPS från WEB01 och godkänd klient. Datatrafik går endast till DB01 på TCP 5432 med separat tjänsteidentitet. |
| Data | `10.40.4.0/23` | DB01 tar emot databasanrop endast från APP01. Klienter, DMZ, utveckling och labb saknar direkt databasåtkomst. |
| Driftstjänster | `10.40.6.0/23` | Separata tjänster för loggning, identitet, policy, status, backup, uppdateringar, DNS och tid. Ingen generell driftzon→alla-regel. |
| Klienter | `10.40.16.0/21` | CLIENT01 når APP01 via HTTPS med verifierad identitet, godkänd enhet och roll. Ingen direkt åtkomst till DB01 eller management. |
| Utveckling/test | `10.40.24.0/22` | Inga aktiva system eller produktionsflöden i detta förslag. Grundregeln neka gäller. |
| Labb | `10.40.28.0/24` | LAB01 får administration från JUMP01 och begränsade stödtjänster. Ingen åtkomst till produktionsapplikation eller databas. |
| Management | `10.40.29.0/24` | ADMIN01 går via JUMP01 för SSH-administration. MFA, enhetskontroll och sessionsloggning krävs. ADMIN01 och JUMP01 ligger i samma zon; värdbrandvägg och gatewaykontroll begränsar deras kommunikation. |
| Integration | `10.40.128.0/17` | Ingen aktiv partner ingår. Inga tillåtande flöden. Varje framtida partner kräver eget delnät, tjänstemål och identitets-/behörighetsregler. |
| Reserv och oallokerat | `10.40.8.0/21`, `10.40.30.0/23`, `10.40.32.0/19`, `10.40.64.0/18` | Inga aktiva tilldelningar eller tillåtande flöden. |

## Kommunikationsskydd och stödtjänster

HTTPS, SSH/SFTP, databas-TLS och logg-TLS ska användas med verifierad motpart och hanterade identiteter. Samma krav gäller inom en zon. Värdfilter krävs där FW-Z inte ser trafiken.

Traditionell DNS på port 53 och NTP på port 123 ger inte i sig fullständigt krypterings- och autentiseringsskydd. Dessa flöden begränsas till de angivna tjänsterna och dokumenteras som kvarstående begränsningar i designen. Intern segmentering eliminerar inte denna begränsning. Därför påstår vi inte att principen om skydd för all kommunikation är fullt uppfylld.

HTTP-trafiken till `46.224.108.117:80` behålls som observation i baslinjen men nekas i förslaget. Ingen regel för HTTPS till samma mål införs eftersom stöd och funktionsbehov inte har visats.

PATCH01 distribuerar paket som införts administrativt efter granskning. Automatisk extern uppdateringshämtning ingår inte; ett framtida sådant behov kräver en separat avgränsad regel.

## Nätverksresiliens och återställning

Dokumentera hur kritiska brandväggar, gateways, DNS, tidstjänster och åtkomstkontroller återställs. Nätverkstekniker ansvarar för nätkomponenterna; Drift & System och respektive tjänsteägare ansvarar för tjänsterna. Säkerhetskopior av konfigurationer och beroenden ska ingå i återställningsplanen.

Testa återställning i en avgränsad miljö och dokumentera faktiskt datum, resultat, återställningsordning och kvarstående brister. Kontrollera att segmentering, neka som standard, identitetskontroll och loggning fungerar efter återställning. Detta återför det tidigare kravet på dokumenterad och testad återställning; genomförda tester påstås inte finnas.

## Ändrings- och kontrollrutin

Tjänsteägaren beskriver behovet. Nätverkstekniker begränsar flödet. Drift & System granskar risk, beroenden och återställning före införande. Testa både tillåten och nekad åtkomst samt loggning. Registrera verkligt datum och testresultat vid genomförandet; dokumentet utgör inte ett påhittat testprotokoll.


## Workshop 1, del 1 – checklista

Principerna är svenska sammanfattningar av NIST SP 800-207, avsnitt 2.1. Alla celler anger konkreta kontroller, beviskrav och ansvar. Beviskraven beskriver vad som behöver visas vid genomförandet; de påstår inte att testerna redan har körts.

| Princip (NIST SP 800-207, 2.1) | Kontrollfråga (ska kunna besvaras nej) | Vad räknas som bevis för ja? | Vem eller vad i vår miljö kan visa beviset? |
|---|---|---|---|
| 1. Datakällor och datortjänster behandlas som resurser | Finns alla system, datakällor och beroenden med ägare i inventeringen? | Inventering som stämmer med verkliga system, inklusive WEB01, APP01, DB01, drifttjänsterna, klient, administration och LAB01. Även externa DNS-/tidsberoenden ska redovisas. | Drift & System sammanställer; tjänsteägarna bekräftar. Adressplanens systemtabell är föreslagen startlista. |
| 2. Kommunikation skyddas oavsett nätplats | Har kommunikationen skydd för konfidentialitet, integritet och motpart även inom samma zon? | Konfiguration och tester av HTTPS/mTLS, databas-TLS, SSH/SFTP och logg-TLS. DNS/NTP på traditionella portar måste redovisas som begränsning; dessa flöden ger inte ett fullständigt ja för hela miljön. | Nätverkstekniker samt applikations-/databasansvariga visar konfigurationer och trafiktester. |
| 3. Åtkomst beviljas per resurs och session | Får en godkänd användare eller tjänst bara nå den resurs och behörighet som behövs? | CLIENT01 når APP01 men nekas DB01 och management. APP01 når sin databas men får inga generella databasrättigheter. Testa nya sessioner och försök till annan resurs. | FW-Z, värdfilter, APP01:s behörigheter och DB01:s konton; IT-Support och databasansvarig genomför test. |
| 4. Dynamisk policy avgör åtkomst | Påverkar identitet, roll och aktuell enhetsstatus åtkomstbeslutet? | Samma åtkomstförsök tillåts med giltig roll/godkänd status och nekas med fel roll, underkänd status eller status äldre än tio minuter. | ID01, STATUS01 och POLICY01 samt åtkomstkontrollen i APP01/JUMP01; identitetsansvarig visar beslut och logg. |
| 5. Tillgångarnas säkerhetsstatus övervakas och mäts | Upptäcks och hanteras säkerhetsbrister löpande på enheterna? | Statusrapporter minst var femte minut, kontroll av uppdateringar och aktivt skydd samt ett dokumenterat fall där en upptäckt brist har hanterats. | STATUS01 och systemens status-/uppdateringsloggar; IT-Support och Drift & System följer upp. |
| 6. Autentisering och auktorisering verkställs och omprövas | Kontrolleras åtkomst före start och återkallas pågående åtkomst när villkoren inte längre gäller? | Test av spärrat konto, återkallad roll och underkänd enhet visar nekat nytt försök och avslutad/begränsad pågående åtkomst inom den föreslagna femminutersgränsen från registrerad ändring. | ID01/POLICY01 samt APP01/WEB01 och JUMP01; identitetsansvarig visar tidsstämplade beslut och sessionsloggar. |
| 7. Insamlad information används för förbättring | Används loggar och trafikdata för att förbättra policyn? | LOG01 innehåller tillåtna/nekade beslut; daglig larmgranskning och månatlig regelgranskning dokumenteras. Ett granskningsfall visar en motiverad förbättring eller ett motiverat beslut att behålla en regel. | Drift & System visar LOG01, trafikbaslinjen och granskningsanteckningar. Nätverkstekniker visar regeländringar. |

### Bedömning av nuvarande dokumenterade förslag

Designen beskriver hur de sju principerna ska hanteras. Tekniskt genomförande är inte styrkt. Traditionell DNS/NTP kvarstår som uttrycklig skyddsbegränsning. Ja-svar får därför inte anges som genomförda kontroller enbart på grund av dessa tabeller.

Källa: [NIST SP 800-207, avsnitt 2.1, sidor 6–7](https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-207.pdf). Testintervall, systemnamn och adresser är gruppens föreslagna designval i detta underlag.


## Workshop 1, del 2 – markeringstabell

Tabellen granskar risker och luckor i det ursprungliga dokumenterade zonsförslaget. Riskerna är inte bevis för att miljön redan är felkonfigurerad. Ändringarna är inarbetade i det reviderade designförslaget. Driftkostnaderna är kvalitativa bedömningar eftersom mätt arbetstid och budget saknas.

| Plats i zonsförslaget | Kontrollfråga som faller | Var den implicita tilliten ligger | Föreslagen ändring | Vad ändringen kostar i drift |
|---|---|---|---|---|
| Hela nätet och dess externa beroenden | Princip 1: visar underlaget en fullständig resursinventering? Ursprungligt underlag styrker inte detta. | Risk att system utan registrerad ägare hamnar utanför kontrollerna. | Använd adressplanens systemlista som inventeringsstart. Drift & System stämmer av mot verkliga tillgångar och registrerar externa DNS-/tidsberoenden. | Inventering vid införande och uppdatering vid varje tillgångsförändring. |
| Inom respektive zon, särskilt management och drift | Princip 2–3: är trafik inom zonerna skyddad och begränsad? Ursprungliga zonregler räcker inte som bevis. | Risk att samma subnät ger fri sidledes åtkomst. | Värdfilter på alla föreslagna värdar. ADMIN01 når endast JUMP01 för SSH; tjänster inom driftzonen har egna regler. | Fler värdregler, central regelhantering och felsökning av nekad trafik. |
| WEB01 → APP01 → DB01 | Princip 3–4: begränsas varje tjänsts åtkomst och identitet? Ursprungliga zonpilar är för breda. | Risk att DMZ får generell applikationsåtkomst eller att hela applikationszonen når alla data. | WEB01→APP01 TCP 443 med mTLS. APP01→DB01 TCP 5432 med TLS och separat, begränsat databaskonto. | Certifikat-/kontohantering och ändringar vid ny applikationsfunktion. |
| ADMIN01 → JUMP01 → hanterade värdar | Princip 4 och 6: finns konkret identitets-, enhets- och sessionskontroll? Ursprungligt underlag beskriver bara kravet. | Risk att managementadress eller tidigare inloggning räcker för fortsatt åtkomst. | MFA, statuskontroll och rollkontroll via ID01/POLICY01. SSH genom JUMP01, sessionsloggning och omprövning minst var femte minut. | Extra inloggningssteg, drift av jumpserver och integration för återkallande av sessioner. |
| Alla hanterade enheter och åtkomstvägar | Princip 5–6: följs säkerhetsstatus och återkallas åtkomst vid förändring? Ursprunglig mekanism saknas. | Risk att en komprometterad eller föråldrad enhet fortsätter vara godkänd. | STATUS01 tar rapporter var femte minut. POLICY01 nekar ny åtkomst vid status äldre än tio minuter och återkallar enligt femminutersregeln. | Installation av rapporteringsfunktioner, drift av kontrolltjänster och åtgärd av brister/felaktiga nekanden. |
| LAB01:s utgående trafik | Princip 2–4: är observerad DNS/NTP/HTTP automatiskt godkänd? Nej, behov och skydd måste bedömas. | Risk att en återkommande anslutning ses som legitim enbart för att den förekommer. | LAB01 använder DNS01 och NTP01. Direkt DNS/NTP ut nekas från klienter/servrar. HTTP till `46.224.108.117:80` nekas. | Omställning av DNS/tid och utredning av den okända HTTP-funktionen; funktionen kan sluta fungera. |
| DNS01/NTP01 → externa mål | Princip 2: ger traditionell DNS/NTP fullständigt kommunikationsskydd? Nej. | Risk att godkänd serveradress förväxlas med verifierad datakälla och skyddad kommunikation. | Begränsa till de angivna målen, logga och redovisa begränsningen. Håll reglerna stängda vid införande om målens lämplighet inte kan bekräftas. | Verifiering av tjänsteleverantör och uppföljning; kvarstående risk behöver hanteras i designbeslutet. |
| Driftstjänster ↔ hanterade värdar | Princip 3: är driftåtkomsten uppdelad per funktion? Ursprunglig generell driftpil är otillräcklig. | Risk att en driftkomponent får bred åtkomst till alla system. | Separera logg-TLS/6514, SFTP-backup/22 och paketdistribution/443. Endast angivna initiatorer och tjänstemål tillåts. | Separata tjänstekonton, lagringsutrymme, underhåll och återställningstester. |
| Integration, utveckling/test och reserver | Princip 3–4: ger ett block automatiskt åtkomst? Det får det inte göra. | Risk att framtida eller partneranslutna system ärver betrodda zonregler. | Inga aktiva partner- eller utvecklingsflöden ingår. Reservblock har inga aktiva tilldelningar. Ny användning kräver eget begränsat beslut. | Handläggning och test av nya behov före aktivering. |
| Loggning och policyuppföljning | Princip 7: finns en rutin som leder från logg till förbättring? Ursprungligt underlag styrker inte detta. | Risk att gamla åtkomstbeslut består utan granskning. | Central logg-TLS till LOG01, daglig larmgranskning och granskning av regler var 30:e dag samt efter större ändring. | Logglagring i 30 dagar och återkommande granskningstid. |
