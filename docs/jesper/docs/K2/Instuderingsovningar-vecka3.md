| ✓ | ? |



## förberedelsefråga: Vem litar vårt labbnät på idag – och varför? Tänk på jump-servern, loggservern och din egen
server. Vad får din server göra, bara för att den sitter på 172.20.1.0/24? Skriv ner ett exempel
på implicit tillit. Det gör inget om du är osäker – vi prövar exemplen på passet.

När man kollar konkret på hur vi loggar in till jump eller labb servern så finns det en viss tillit där ender jump kan koppla till labb servern. Man kan inte komma åt denna genom andra vägar. Med reflektion på föregående övningsuppgifter med gömda servrar så kan det finnas vissa delar av segmenteringen där denna tiliten kan skapa problemer då labben har åtkomst till internet om den utnyttjas på fel sätt.

| ✓ | ? |

| ? | - (Osäker) Rätta snälla


## Ö1

1. **Alla datakällor och datortjänster betraktas som resurser.**  
   ctf, jump och loggservern anses som resurser och är också delar av nätverket som behöver skyddas | ✓ |

2. **All kommunikation skyddas, oavsett var i nätverket den sker.**  
   bara för att servern är inom en segmentering gör det inte att segmentet i sig är betrott | ✓ |

3. **Åtkomst till enskilda företagsresurser ges för varje session.**  
   Att det loggas var gång någon försöker komma in på servern samt att det är uppmuntrat att logga in via ssh till servern med nycklar skapar säkerhet men betyder inte att du kommer kunna logga in imorgon om nya säkerhetsregler ändras. | ? | - Osäker

4. **Åtkomst till resurser styrs av dynamiska regler. Reglerna tar hänsyn till den observerbara statusen för klientens identitet, applikationen eller tjänsten och den enhet som begär åtkomst. De kan även ta hänsyn till beteende och omgivande förhållanden.**  
  Att som basis att endast kunna använda sudo på sin egna server men inte på jump servern är ett bra exempel på least privilege | ? | - Osäker

5. **Företaget övervakar och bedömer säkerheten hos alla egna och tillhörande resurser.**  
   Kontrollera fortlöpande säkerheten på ctf, jump, loggservern och tillhörande labb servrar. Begränsa eller neka åtkomst för enheter med säkerhetsproblem. | ✓ |

6. **Autentisering och behörighetskontroll för alla resurser är dynamiska och tillämpas strikt före åtkomst.**  
   Kontrollera identitet och behörighet innan åtkomst ges. Granska åtkomsten igen under användning när reglerna kräver det, till exempel vid misstänkt aktivitet. | ✓ |

7. **Företaget samlar in så mycket information som möjligt om resursernas, nätverksinfrastrukturens och kommunikationens aktuella status och använder informationen för att förbättra säkerheten.**  
   Samla in och granska information om enheter, nätverk och åtkomstförfrågningar. Använd den för att förbättra säkerhetsregler och skydd. | ✓ |

## Ö2
A. 2 | ✓ |
B. 3 | ✓ |
C. 1 | ✓ |
D. 4 | ✓ |

## Ö3
1. implicit tillit | ✓ |
Motivering: Tillit ser till att endast 172.20.1.0/24 får nå loggservern

2. implicit tillit, typ? | ✓ |
Motivering: Ser till att endast jump servern får ssh:a till slutändan, alla servrar är ganska brett brett

3. inte implicit tillit | ✓ |
Motivering: Tillit är baserat på variabler fylls, detta är en regel som följs.

4. implicit tillit | ✓ |
Motivering: internt nät är säkert och behöver inte ha andra specifika regler

5. inte implicit tillit  | ✓ |
Motivering: Detta är ett subjekt som ger en tillgång till specifik miljö, inte tillit mellan två delar/segment


## Ö4
identitet - vem försöker komma åt databasen | ✓ |
plats - vart kommer begäran från? plats, ip-address? | ? |
token - Är nyckel eller token rätt? | ? |
resurs - känslighet av databasen? Behövs högre elevering av rättigheter eller passar det med användarens token/nyckel/tag? | ✓ |

Rätt svar: 
Identitet: vem är användaren, är hen autentiserad, med vilken metod (nyckel, MFA)?
Enhet: är det en hanterad och uppdaterad enhet, har den rätt certifikat?
Resurs: hur känslig är databasen, vilken operation begärs (läsa eller skriva)?
Kontext: tid på dygnet, varifrån begäran kommer, avvikande beteende (t.ex. tusentals rader på kort tid).

Reflektion: Osäkerheten skedde när jag behöver komma på egna "Begäran" och veta vad som faktiskt är rätt i detta sammanhang. Känns som öppet för förslag?

## Ö5
Traditional: stor server med antingen små makrosegmenteringar och få regler | ? |
advanced: skapning av flera segmenterade sektioner tillsammans med fasta regler mellan tjänster och servrar. | ? |

Rätt svar: 
Traditional: stor perimeter och makrosegmentering med få, statiska regler. Allt innanför perimetern når i stort sett allt.
Advanced: fler och mindre segment, regler mellan arbetslaster och tjänster (mikrosegmentering i delar av miljön), med mer automatiserad hantering.

Reflektion: Jag tror jag förstår vad tanken är mellan det traditionella och det mer advancerade och destu högre upp i skalan man går ju mer åtgärder kan man implementera för att säkerställa att attack ytan är så liten så möjligt och att spårbarheten ökas.

## Ö6 
1. ”Klientzonen får inte nå serverzonen, utom webbservern på tcp/443.” - Makro | ✓ |
2. ”Klientzonen får inte nå serverzonen, utom webbservern på tcp/443.” - Micro | ✓ |
3. ”Driftzonen får nå allt.” - Makro | ✓ |


## Ö7
1. Från internet till din webbserver, tcp/80 - internet --> webbserver via tcp/80, hetzner kan filtreras | ✓ |
2. Från jump-servern (172.20.1.2) till din server, tcp/22 - jump server --> till min server via tcp/22, hetzner kan inte filtrera, internt nätverk, endast värden | ✓ |
3. Från din server till loggservern (172.20.1.58), tcp/6514 - min server --> loggserver via tcp/6514, hetzner kan inte filtrera, internt nätverk, endast väden | ✓ |
4. Från din server till en uppdateringsserver på internet, tcp/443 - min server --> uppdateringsserver på internet via tcp/443, heztner kan filtrera utgående och ingående trafik | ✓ |

## Ö8
Default deny i båda riktningarna, varför?
Att kunna stoppa utgående attacker kan skydda mikrosegmenterade delar av server som är skyddade. Genom default deny kan dessa skyddas med relativt enkla regler och värden. Detta kan också hindra attackerare som redan har lyckats att komma in i miljön och försöker att antingen ladda ner eller ladda upp filer utanför systemet. | ✓ |

## Ö9
Appserver: 10.40.1.20
Webbserver: 10.40.1.10

| Källzon | Målzon | Protokoll | Port | Riktning | Motivering (varför denna funktion?) | Filtreras var? |
|---|---|---|---|---|---|---|
| 10.40.1.20 | 10.40.1.10 | TCP | 8080 | Webb -> App | Webben hanterar input från klienter som sedan registreras på Appserver | Värden hjälper att filtrera detta då dessa är i ett privat nätverk| | ✓ |

## Ö10

| Subject |Action |Target |Condition |
|---|---|---|---|
| admin | hantering av loggar | databas tcp5432| Endast via Jump server med registrerad nyckel eller designerad tag på datorn | | ✓ |
| klient | användning av hemsida/portal | webbportalen tcp443| Endast tillgång till personal/användare med godkända rättigheter, om fel inloggning sker larmas det om fler fel sker under kort tid | | ✓ |



Tankar efter övningar: Tycker att jag stöter på mer frågetecken än svar när det kommer till att "komma på" olika scenarion och händelser utan konkret fakta..