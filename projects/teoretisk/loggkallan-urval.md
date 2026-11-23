# Loggkällekarta och urval

## Syfte

Teamet samlar in loggar från de fyra servrarna och från molnregeln för F1, om molnplattformen kan skicka sådana loggar. Källorna ska hjälpa teamet att undersöka systemfel, inloggningar, systemändringar och nätverksflödena F1–F4.

Loggarna skickas till den centrala loggservern `172.20.1.58:6514` med TCP/TLS. Mottagaren måste vara konfigurerad för TLS på port 6514. Källorna ska använda RFC 5424 för syslog-formatet. TLS skyddar transporten. <citation src="18,21,22"></citation>

**Exempelraderna nedan är fiktiva.** De visar ett möjligt format. Den exakta raden kan skilja sig mellan distributioner och program.

## Loggkällekarta

| Loggkälla | Tilldelad adress | Labbadress | Segment | Ansvarig | Loggar som samlas in |
|---|---|---|---|---|---|
| `elev-05` | `10.40.4.10` | `172.20.1.105` | Webb/DMZ (`10.40.4.0/28`) | Ludvig Alm | System, autentisering, audit, värdbrandvägg och webbserver |
| `elev-10` | `10.40.4.20` | `172.20.1.110` | Applikation (`10.40.4.16/28`) | Stefan Antovic | System, autentisering, audit, värdbrandvägg och applikation |
| `elev-43` | `10.40.4.34` | `172.20.1.143` | Databas (`10.40.4.32/29`) | Jesper Thomsen | System, autentisering, audit, värdbrandvägg och databas |
| `elev-35` | `10.40.4.42` | `172.20.1.135` | Klient (`10.40.4.40/29`) | Edvin Pihl | System, autentisering, audit och värdbrandvägg |

Labbadressen och den tilldelade adressen är två adresser för samma server. Använd servernamnet, till exempel `elev-05`, som stabil värdidentitet. Märk också loggar med miljön, till exempel `lab`. RFC 5424 har fält för bland annat tid, värdnamn och programnamn. <citation src="18"></citation>

## Loggkällor
#### NOTERA: Exempelrader är endast exempel och kommer verifieras från varje elevserver.

| Källa | Var/hur den läses | Exempelrad (fiktiv) | Vilken fråga den besvarar | Rotation | Hur långt bakåt | Tidsformat |
|---|---|---|---|---|---|---|
| System och tjänster | `journald`. Rsyslog läser lokala meddelanden från journalen och skickar dem till loggservern. Kontrollera att samma journal inte läses in två gånger. | `2026-11-09T10:12:31+00:00 elev-05 systemd[1]: Started nginx.service.` | Vilken tjänst startade, stoppade eller gav ett fel? När ändrades systemets tillstånd? | Journald roterar journalfiler automatiskt enligt sin konfiguration och sina lagringsgränser. | **Förslag:** minst 30 dagar centralt. Lokal historik beror på journalds lagringsgränser. | RFC 5424 använder en ISO 8601/RFC 3339-tidsstämpel med tidszon. Använd UTC där det går. Journald kan visas med ISO-format. <citation src="2"></citation> |
| Autentisering | SSH-, PAM- och `sudo`-meddelanden i journalen eller i distributionens autentiseringslogg. Rsyslog skickar meddelandena vidare. | `2026-11-09T10:14:02+00:00 elev-35 sshd[821]: Failed password for invalid user test from 192.0.2.40 port 51122 ssh2` | Vem försökte logga in? Från vilken adress? Lyckades inloggningen? Användes `sudo`? | Om loggen finns i journalen följer den journalds rotation. Om den skrivs till en fil följer den distributionens logrotate-konfiguration. | **Förslag:** minst 30 dagar centralt. Kontrollera lokal lagring och logrotate. | RFC 5424 vid central mottagning. Källtiden kan bero på distributionens format. |
| Audit | `auditd` skriver normalt till `/var/log/audit/audit.log`. Välj auditregler med `auditctl` eller beständiga regel-filer. Skicka audit-händelser via auditens dispatcher/syslog-plugin om den finns i systemet. Behåll den lokala auditloggen. | `type=SYSCALL msg=audit(1794219242.310:24287): arch=c000003e syscall=2 success=no exit=-13 auid=1000 uid=1000 pid=3538 comm="cat" key="ssh_config"` | Vilken användare eller process utförde en övervakad åtgärd? Vilken åtgärd skedde? Lyckades den? | `auditd` använder normalt storleksbaserad rotation. Antal filer och storleksgränser styrs i auditd-konfigurationen. | **Förslag:** minst 30 dagar centralt. Lokal historik beror på auditd-inställningar och diskutrymme. Övervaka utrymmet så att auditloggen inte slutar skriva. | Audit-tiden visas ofta som Unix-tid i `msg=audit(...)`. RFC 5424-tidsstämpeln kan visa mottagen eller vidarebefordrad tid. Behåll audit-tiden i meddelandet. <citation src="6,8"></citation> |
| Värdbrandvägg | nftables skriver matchade paket till kärnloggen. Läs loggen via `journald` eller den lokala syslog-tjänsten. Använd tydliga prefix för flöde och riktning. | `2026-11-09T10:15:10+00:00 elev-10 kernel: F3-IN-DROP IN=eth0 SRC=172.20.1.110 DST=172.20.1.143 PROTO=TCP DPT=5432` | Tillät eller nekade värden ett försök att följa ett definierat flöde? Vilka var käll- och destinationsadresserna och porten? | Om loggen går till journalen följer den journalds rotation. | **Förslag:** minst 30 dagar centralt. Begränsa loggning och sätt hastighetsgräns för att minska volymen. | RFC 5424 vid central mottagning. Händelsetiden bör innehålla tidszon. <citation src="11,13,2"></citation> |
| Webbserver på `elev-05` | Webbserverns åtkomst- och fellogg. Läs filen eller tjänsteloggen enligt webbserverns konfiguration. | `192.0.2.40 - - [09/Nov/2026:10:16:04 +0000] "GET /orders HTTP/1.1" 200 1240` | Vilken klient begärde vilken sida? Vilket svar gav webbservern? | Styrs av webbservern eller logrotate. Kontrollera den faktiska konfigurationen. | **Förslag:** minst 30 dagar centralt. Lokal historik beror på logrotation och diskutrymme. | Exemplet använder en tid med tidszon. Vid vidarebefordran ska RFC 5424-tidsstämpeln vara ISO 8601/RFC 3339. |
| Applikation på `elev-10` | Applikationens tjänstelogg eller loggfil. Samla fel och relevanta händelser för anrop mot F2 och F3. | `2026-11-09T10:17:02+00:00 elev-10 order-api: Database request failed; request_id=abc123` | Tog applikationen emot portalens anrop? Försökte den läsa eller skriva orderdata? Uppstod ett fel? | Styrs av applikationen eller logrotate. Kontrollera den faktiska konfigurationen. | **Förslag:** minst 30 dagar centralt. Lokal historik beror på loggrotation och diskutrymme. | RFC 5424 vid central mottagning. Använd ISO 8601/RFC 3339 med tidszon. |
| Databas på `elev-43` | Databasens anslutnings-, autentiserings- och fellogg. Aktivera inte detaljerad frågeloggning om den inte behövs för övningen. | `2026-11-09T10:18:11+00:00 elev-43 postgres[900]: connection authorized: user=app database=orders` | Kunde applikationen ansluta? Lyckades autentiseringen? Uppstod databasfel? | Styrs av databasens logginställningar eller logrotate. Kontrollera den faktiska konfigurationen. | **Förslag:** minst 30 dagar centralt. Lokal historik beror på databasens loggrotation och diskutrymme. | RFC 5424 vid central mottagning. Använd ISO 8601/RFC 3339 med tidszon. |
| Molnregel för F1 | Molnplattformens regel- eller flödeslogg. Skicka den till loggservern om plattformen stöder detta. Den här loggen kommer inte automatiskt från `elev-05`. | `2026-11-09T10:19:20+00:00 cloud-firewall: action=ALLOW src=198.51.100.25 dst=10.40.4.10 proto=TCP dport=80` | Tillät eller nekade molnregeln trafik från Internet till `elev-05`? | Styrs av molnplattformens loggtjänst och exportinställningar. | **Förslag:** minst 30 dagar centralt efter export. Kontrollera även plattformens egen lagringstid. | RFC 5424 vid central mottagning. Bevara den ursprungliga händelsetiden. |

Journald kan visa poster med ISO 8601-tider. Auditposter kan bestå av flera rader med samma händelse-ID. Samla därför alla auditposter som hör till samma händelse. Auditloggens lokala rotation är normalt storleksbaserad. <citation src="2,6,8"></citation>

nftables kan skriva matchade paket till kärnloggen. Använd `log` endast för de regler som behövs. Lägg till hastighetsbegränsning där många paket kan matcha. <citation src="13,11"></citation>

### Retention och rotation

**Förslag för labben:** behåll loggarna i minst 30 dagar på den centrala loggservern. Det är en föreslagen labbinställning, inte en uppgift som redan finns i adressplanen. Kontrollera att serverns loggplattform har stöd för den inställningen.

Rotation och retention är olika saker:

- **Rotation** skapar en ny loggfil eller journalfil.
- **Retention** anger hur länge loggar sparas innan de tas bort.
- **Central lagring** måste ha en egen retentionregel. Källornas lokala rotationsinställningar styr inte hur länge loggservern sparar mottagna loggar.
- **Audit** ska fortsätta skriva lokalt. Skicka också kopior till loggservern. Övervaka disk, auditd och rsyslog-köer.

Rsyslog kan buffra meddelanden i en kö när mottagaren inte är tillgänglig. Ange en köstorlek och en diskgräns som passar labbserverns diskutrymme. <citation src="22,23"></citation>

## Urval av nätverksflöden

Logga nya anslutningar och nekade försök. Undvik att logga varje paket i en etablerad anslutning. Använd tydliga prefix, till exempel `F2-IN-ALLOW` och `F2-IN-DROP`. Då går det lättare att söka efter rätt flöde.

| Flöde | Loggval | Var loggen skapas |
|---|---|---|
| **F1** Internet → `elev-05` (`10.40.4.10`), TCP/80 | Logga nya anslutningar och nekanden i molnregeln och på värden. `0.0.0.0/0` är regelns källområde. Loggen ska visa den faktiska källadressen. | Molnregel och värdbrandvägg på `elev-05` |
| **F2** `elev-05` (`10.40.4.10`) → `elev-10` (`10.40.4.20`), TCP/8080 | Logga nya anslutningar och nekanden. | Utgående på `elev-05`, inkommande på `elev-10` |
| **F3** `elev-10` (`10.40.4.20`) → `elev-43` (`10.40.4.34`), TCP/5432 | Logga nya anslutningar och nekanden. | Utgående på `elev-10`, inkommande på `elev-43` |
| **F4** `elev-35` (`10.40.4.42`) → `elev-05` (`10.40.4.10`), TCP/80 | Logga nya anslutningar och nekanden. | Utgående på `elev-35`, inkommande på `elev-05` |
| **F5a** `elev-05` (`172.20.1.105`) → `172.20.1.58:6514` | Tillåt TCP/TLS till loggservern. Logga fel i loggtransporten. | Utgående på `elev-05`; inkommande på loggservern |
| **F5b** `elev-10` (`172.20.1.110`) → `172.20.1.58:6514` | Tillåt TCP/TLS till loggservern. Logga fel i loggtransporten. | Utgående på `elev-10`; inkommande på loggservern |
| **F5c** `elev-43` (`172.20.1.143`) → `172.20.1.58:6514` | Tillåt TCP/TLS till loggservern. Logga fel i loggtransporten. | Utgående på `elev-43`; inkommande på loggservern |
| **F5d** `elev-35` (`172.20.1.135`) → `172.20.1.58:6514` | Tillåt TCP/TLS till loggservern. Logga fel i loggtransporten. | Utgående på `elev-35`; inkommande på loggservern |

F5 är loggtransport. F5 är inte ett applikationsflöde. Begränsa brandväggsregeln till de fyra labbadresserna som källor och `172.20.1.58`, TCP-port `6514`, som destination. Loggservern ska tillåta motsvarande inkommande trafik.

Vid central mottagning ska rsyslog använda TCP/TLS och verifiera servercertifikatet. RFC 5424 är meddelandeformatet. RFC 5425 beskriver syslog över TLS.

## Källor som stryks

| Källa eller urval som stryks | Varför |
|---|---|
| `logger` som egen loggkälla | `logger` kan skicka ett testmeddelande. Det samlar inte automatiskt in system-, audit- eller brandväggsloggar. Använd det för att testa F5. |
| Dubbel inläsning av journald | Samma journalpost kan skickas två gånger om rsyslog läser journalen via mer än en väg. Kontrollera systemets befintliga koppling innan ni lägger till en ny. |
| Loggning av varje paket | Det skapar stor loggvolym. Det gör det svårare att hitta viktiga händelser. Samla i stället in nya anslutningar och nekanden. |
| Fullständig paketfångst | Den behövs inte för att besvara frågorna i F1–F5. Lägg bara till den om övningen kräver nätverksforensik. |
| Detaljerad databasfrågeloggning | Den behövs inte för att kontrollera anslutning, autentisering och fel i F3. Samla bara in frågeinnehåll om övningen kräver det. |
| Loggar från andra värdar och tjänster | De finns inte i adressplanen eller flödestabellen. De ligger utanför detta urval. |

## Kontroll före inlämning

- Kontrollera att de fyra klienterna kan ansluta till `172.20.1.58:6514`.
- Kontrollera TLS-certifikat och certifikatnamn på klient och mottagare.
- Skicka ett testmeddelande med `logger` från varje värd.
- Kontrollera att mottagaren visar rätt värdnamn och tidsstämpel.
- Kontrollera att auditposter kommer med till loggservern och finns kvar lokalt.
- Kontrollera att central retention är satt till minst 30 dagar, om detta är valt som labbkrav.
- Kontrollera att F1-loggar från molnregeln faktiskt exporteras. De skapas inte automatiskt på `elev-05`.