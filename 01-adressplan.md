# Adressplan för 10.40.0.0/16

**Dokumentstatus:** komplett designförslag utifrån gruppens adressplan, tillitsregler och rapporterade trafikbaslinje. Föreslagna adresser, komponenter och tjänsteval är designbeslut i detta underlag, inte observationer av den befintliga miljön. Konfigurationer och tester har inte genomförts här.


## Läsanvisning och dokumentindelning

Allt innehåll i det reviderade paketet är samlat i de tre befintliga dokumenttyperna:

- `adressplan.md`: zoner, adressberäkningar, tillgångsförteckning och föreslagna systemroller.
- `tillitsregler.md`: åtkomstregler samt workshop 1:s checklista och markeringstabell.
- `trafikbaslinje.md`: tidigare rapporterade observationer samt workshop 2:s föreslagna flöden i ett eget avsnitt.

Workshop-avsnitten behåller sina namn för att vara lätta att hitta. De behöver inga separata filer. Detta paket ersätter innehållet i de tre motsvarande dokumenten; projektets befintliga README behålls.

Zonblocken, zonidén, grundreglerna och trafikobservationerna kommer från gruppens tidigare material. Systemnamn, rolladresser, tjänsteval och kontrollintervall är tillagda designförslag. Underlaget visar inte att systemen har installerats eller att tester genomförts. Lärarens fullständiga uppgiftsbeskrivning har inte funnits tillgänglig, så eventuella krav på separata inlämningsfiler behöver kontrolleras mot den.

## Förutsättningar

- Uppdragsgivarens privata IPv4-adressutrymme är `10.40.0.0/16`.
- Planen omfattar IPv4. Enligt gruppens förutsättningar är IPv6 avstängt på labbservrarna; detta har inte verifierats och säger inget om övriga system.
- Huvudblocken är sorterade efter stigande nätadress. Storlek, nätgränser och sammanhängande tilldelning ger möjlighet till ruttsummering när routning och åtkomstregler tillåter det. Sortering i tabellen skapar inte i sig summeringsmöjligheter.
- Adressintervallen nedan avser användbara värdadresser i respektive block. Samlingsblocket för produktion tilldelas inte som ett parallellt nät.
- Zon eller IP-adress är inte identitetsbevis. Tillitsregler och tjänstespecifika kontroller gäller även inom zoner.

## Logisk zonindelning

```text
Internet ── [yttre brandvägg] ── DMZ
                                 │
                       endast beslutade flöden
                                 │
Klienter ────────────────── Applikation ── Data
                                 │
                           Driftstjänster

Management ── begränsad administration ── namngivna system
Utveckling/test och labb ── isolerade från produktion som standard
Integrationer ── separata delzoner/gateways per partner eller tjänst
```

Linjerna visar möjliga funktionella relationer, inte generell tillåtelse. Riktning, tjänst och kontrollpunkt anges per flöde i `trafikbaslinje.md`, under ”Workshop 2 – föreslagna flöden”. En yttre brandvägg räcker inte för att beskriva kontrollerna mellan eller inom de interna zonerna.

## Huvudblock

| Prefix | Syfte | Användbart adressintervall | Ansvarig funktion | Reserverat utrymme | Uträkning och kommentar |
|---|---|---|---|---|---|
| `10.40.0.0/20` | Serverinfrastruktur, samlingsblock | `10.40.0.1`–`10.40.15.254` | Drift & System | Delvis | 32 − 20 = 12 hostbitar; 2^12 = 4096 adresser, 4094 användbara. Nät: 10.40.0.0; broadcast: 10.40.15.255. Överordnat block. Tilldelning sker endast genom delnäten i nästa tabell. |
| `10.40.16.0/21` | Klienter och arbetsstationer | `10.40.16.1`–`10.40.23.254` | IT-Support | Nej | 32 − 21 = 11 hostbitar; 2^11 = 2048 adresser, 2046 användbara. Nät: 10.40.16.0; broadcast: 10.40.23.255. Åtkomst till särskilt godkända användartjänster. |
| `10.40.24.0/22` | Utveckling och test | `10.40.24.1`–`10.40.27.254` | Utvecklingsteam | Nej | 32 − 22 = 10 hostbitar; 2^10 = 1024 adresser, 1022 användbara. Nät: 10.40.24.0; broadcast: 10.40.27.255. Åtskilt från produktion; särskilt reglerade undantag. |
| `10.40.28.0/24` | Labbservrar och testriggar | `10.40.28.1`–`10.40.28.254` | Labbansvarig | Nej | 32 − 24 = 8 hostbitar; 2^8 = 256 adresser, 254 användbara. Nät: 10.40.28.0; broadcast: 10.40.28.255. Isolerad labbmiljö. |
| `10.40.29.0/24` | Management och out-of-band | `10.40.29.1`–`10.40.29.254` | Nätverkstekniker | Nej | 32 − 24 = 8 hostbitar; 2^8 = 256 adresser, 254 användbara. Nät: 10.40.29.0; broadcast: 10.40.29.255. Separat administrationszon. Administration sker genom managementzonen och jumpservern. Ursprunglig avsikt omfattar även out-of-band; separat åtkomstväg och teknisk lösning återstår att specificera. |
| `10.40.30.0/23` | Framtida expansion | `10.40.30.1`–`10.40.31.254` | Ej tilldelad | Ja | 32 − 23 = 9 hostbitar; 2^9 = 512 adresser, 510 användbara. Nät: 10.40.30.0; broadcast: 10.40.31.255. Ingen aktiv tilldelning före beslut om ägare, syfte och regler. |
| `10.40.32.0/19` | Framtida tjänster | `10.40.32.1`–`10.40.63.254` | Arkitektur | Ja | 32 − 19 = 13 hostbitar; 2^13 = 8192 adresser, 8190 användbara. Nät: 10.40.32.0; broadcast: 10.40.63.255. Ingen aktiv tilldelning före beslut om ägare, syfte och regler. |
| `10.40.64.0/18` | Oallokerat utrymme | `10.40.64.1`–`10.40.127.254` | Ej tilldelad | Ja | 32 − 18 = 14 hostbitar; 2^14 = 16384 adresser, 16382 användbara. Nät: 10.40.64.0; broadcast: 10.40.127.255. Inga aktiva tilldelningar eller tillåtande åtkomstregler. |
| `10.40.128.0/17` | Integrationer och partneranslutningar | `10.40.128.1`–`10.40.255.254` | Integration / Gateway | Nej | 32 − 17 = 15 hostbitar; 2^15 = 32768 adresser, 32766 användbara. Nät: 10.40.128.0; broadcast: 10.40.255.255. Privat adressutrymme; dela vidare per partner eller integration före användning. |

## Delnät inom produktionsblocket 10.40.0.0/20

Dessa fem block utgör tillsammans hela produktionsblocket och överlappar inte varandra.

| Prefix | Syfte | Användbart adressintervall | Ansvarig funktion | Reserverat utrymme | Uträkning och kommentar |
|---|---|---|---|---|---|
| `10.40.0.0/23` | DMZ | `10.40.0.1`–`10.40.1.254` | Drift & System | Nej | 32 − 23 = 9 hostbitar; 2^9 = 512 adresser, 510 användbara. Nät: 10.40.0.0; broadcast: 10.40.1.255. Publika tjänster, omvända proxyservrar eller andra särskilt publicerade funktioner. |
| `10.40.2.0/23` | Applikation | `10.40.2.1`–`10.40.3.254` | Drift & System | Nej | 32 − 23 = 9 hostbitar; 2^9 = 512 adresser, 510 användbara. Nät: 10.40.2.0; broadcast: 10.40.3.255. Applikationsservrar och interna API:er. |
| `10.40.4.0/23` | Data | `10.40.4.1`–`10.40.5.254` | Drift & System | Nej | 32 − 23 = 9 hostbitar; 2^9 = 512 adresser, 510 användbara. Nät: 10.40.4.0; broadcast: 10.40.5.255. Databaser, filservrar och känslig lagring; åtkomst per tjänst. |
| `10.40.6.0/23` | Driftstjänster | `10.40.6.1`–`10.40.7.254` | Drift & System | Nej | 32 − 23 = 9 hostbitar; 2^9 = 512 adresser, 510 användbara. Nät: 10.40.6.0; broadcast: 10.40.7.255. Övervakning, loggning, backup, patchning och konfigurationshantering. |
| `10.40.8.0/21` | Reserv inom serverblocket | `10.40.8.1`–`10.40.15.254` | Drift & System | Ja | 32 − 21 = 11 hostbitar; 2^11 = 2048 adresser, 2046 användbara. Nät: 10.40.8.0; broadcast: 10.40.15.255. Ingen aktiv tilldelning före beslut om syfte och regler. |

## Management och out-of-band

`10.40.29.0/24` är managementzon. Administration sker från administratörsenheten genom jumpservern och interna brandväggen. Detta beskriver administration via det planerade nätet. Den tidigare benämningen ”Management & Out-of-Band” behålls som planeringsavsikt. En separat out-of-band-väg är inte specificerad här; anslutning, oberoende vid nätavbrott, autentisering och nödvändiga regler behöver definieras innan den kan betraktas som en färdig lösning.

## Kapacitetskontroll

Huvudblocken täcker tillsammans hela `10.40.0.0/16` utan luckor eller överlapp. Produktionsdelnäten omfattar 4 × 512 + 2048 = 4096 adresser, vilket motsvarar `/20`.

Adressberäkningarna visar teknisk giltighet. De ursprungliga blockstorlekarna behålls för att undvika onödig omnumrering. Detta är ett bevarande av gruppens plan, inte en verifierad kapacitetsdimensionering. Integrationsblocket hålls utan aktiva partneranslutningar tills en faktisk integration beställs; ingen generell trafik tillåts där.


## Tillgångsförteckning

Detta är ett planeringsregister över zoner och tillgångsgrupper, inte en verifierad lista över installerade servrar. Konkreta systemroller i nästa avsnitt är tillagda designförslag.

| ID | Tillgång eller grupp | Nät | Exempel på innehåll | Föreslagen ansvarig | Kritikalitet / exponering |
|---|---|---|---|---|---|
| ZONE-DMZ | DMZ-zon | `10.40.0.0/23` | Publika webbservrar, omvänd proxy, WAF | Drift & System; bekräfta tjänsteägare | Hög; endast godkända tjänster nås från internet |
| ZONE-APP | Applikationszon | `10.40.2.0/23` | Applikationsservrar, interna API:er | Drift & System; bekräfta applikationsägare | Hög; endast åtkomst från godkända zoner och tjänster |
| ZONE-DATA | Datalagringszon | `10.40.4.0/23` | Databaser, filservrar, lagring | Drift & System; bekräfta dataägare | Hög; ingen direkt åtkomst från internet eller klienter |
| ZONE-OPS | Driftstjänster | `10.40.6.0/23` | Övervakning, loggning, backup, patchning | Drift & System | Hög; begränsad till dokumenterade driftbehov |
| ZONE-CLIENT | Klientzon | `10.40.16.0/21` | Personalens datorer och arbetsstationer | IT-support | Medel; ingen direkt databasåtkomst |
| ZONE-DEVTEST | Utveckling och test | `10.40.24.0/22` | Utvecklingsservrar och testmiljöer | Utvecklingsteam | Medel; åtskild från produktion |
| ZONE-LAB | Labbzon | `10.40.28.0/24` | Labbservrar och testriggar | Labbansvarig | Varierar; begränsade kopplingar till produktion |
| ZONE-MGMT | Management och out-of-band | `10.40.29.0/24` | Administratörsenheter, jumpserver, hanteringsgränssnitt; separat out-of-band-väg återstår att specificera | Nätverkstekniker | Hög; endast behöriga administratörer |
| ZONE-INT | Integration | `10.40.128.0/17` | Integrationsgateways och partneranslutningar | Integration / Gateway | Hög; dela upp per partner eller integration |
| RES-PROD | Reserv inom produktionsblocket | `10.40.8.0/21` | Ej tilldelad | Drift & System eller Arkitektur; bekräfta | Reserverad; inga aktiva värdar |
| RES-30 | Framtida expansion | `10.40.30.0/23` | Ej tilldelad | Ej tilldelad | Reserverad; inga aktiva värdar |
| RES-32 | Reserverat tjänsteutrymme | `10.40.32.0/19` | Ej tilldelad | Arkitektur | Reserverad; inga aktiva värdar |
| RES-64 | Öppet adressutrymme | `10.40.64.0/18` | Ej tilldelad | Ej tilldelad | Oallokerad; inga aktiva värdar |

## Konkreta systemroller i förslaget

Adresserna nedan är föreslagna tilldelningar. Nya rolladresser är valda för att göra flödestabellen komplett och ska inte läsas som upptäckta system.

| System/roll | Adress | Funktion och vald tjänst | Ansvarig funktion |
|---|---|---|---|
| FW-Y | Management `10.40.29.2`; publik adress tilldelas av uppkopplingen | Publicerar endast webb på TCP 443 till WEB01. Inkommande TCP 80 nekas. | Nätverkstekniker |
| FW-Z | Gateway `.1` i varje aktivt delnät | Filtrerar mellan zoner och styr utgående trafik. För IPv4 är detta `10.40.0.1`, `10.40.2.1`, `10.40.4.1`, `10.40.6.1`, `10.40.16.1`, `10.40.24.1`, `10.40.28.1`, `10.40.29.1`. | Nätverkstekniker |
| WEB01 | `10.40.0.10` | HTTPS-ingång och omvänd proxy för den föreslagna webbtjänsten. | Drift & System |
| APP01 | `10.40.2.10` | Webbapplikation/API över HTTPS, TCP 443. | Applikationsansvarig |
| DB01 | `10.40.4.10` | Föreslagen PostgreSQL-databas med TLS på TCP 5432. Databasmotorn är ett nytt tjänsteval för förslaget. | Databasansvarig |
| LOG01 | `10.40.6.10` | Central loggmottagare, syslog över TLS på TCP 6514. | Drift & System |
| ID01 | `10.40.6.20` | Identitetstjänst över HTTPS, MFA för administratörer, identiteter och roller för applikationen. | Identitetsansvarig |
| POLICY01 | `10.40.6.21` | Föreslagen policyfunktion över HTTPS för åtkomstbeslut och omprövning. | Identitetsansvarig |
| STATUS01 | `10.40.6.22` | Föreslagen mottagare för hanterade enheters statusrapporter över HTTPS. | IT-Support |
| BACKUP01 | `10.40.6.30` | Tar emot säkerhetskopior via SFTP på TCP 22, separata konton och kataloger. | Drift & System |
| PATCH01 | `10.40.6.40` | Intern distribution av administrativt införda och granskade uppdateringspaket över HTTPS. Ingen extern hämtning ingår i flödesförslaget. | Drift & System |
| DNS01 | `10.40.6.53` | Intern DNS för klienter och servrar; UDP/TCP 53. Föreslagen extern vidarebefordran till det tidigare observerade målet `185.12.64.1`. | Nätverkstekniker |
| NTP01 | `10.40.6.123` | Intern tidskälla, UDP 123. Föreslagen extern källa är det tidigare observerade målet `185.12.64.2`. | Nätverkstekniker |
| ADMIN01 | `10.40.29.10` | Hanterad administratörsenhet. | Nätverkstekniker |
| JUMP01 | `10.40.29.20` | Administrationsgateway/jumpserver med SSH, MFA och sessionsloggning. | Nätverkstekniker |
| CLIENT01 | `10.40.16.10` | Representativ hanterad användarklient för applikationens tester. | IT-Support |
| LAB01 | `10.40.28.110` | Föreslagen framtida roll för Elev 10. Rollmappningen är ett antagande för designen, ingen genomförd flytt. | Labbansvarig |

De logiska kontrollfunktionerna ID01, POLICY01 och STATUS01 behöver en teknisk implementation för att policyn ska fungera. Adresser och API-portar är här specificerade som designkrav; dokumenten bevisar inte att en sådan integration finns.

De tidigare observerade externa DNS-/NTP-adresserna återanvänds endast som destinationsval i förslaget. Ägarskap, tillgänglighet och lämplighet har inte verifierats. Om de inte kan godtas ska reglerna hållas stängda och destinationerna bytas genom dokumenterat beslut.
