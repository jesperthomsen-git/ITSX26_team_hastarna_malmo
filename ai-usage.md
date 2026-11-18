# 03 AI-användningslogg

## tillitsregler
| Tillfälle | Fråga/prompt till AI | Sammanfattning av AI-svar | Vad kontrollerade du själv? | Vad ändrade eller valde du bort? | Slutsats med egna ord |
|---|---|---|---|---|---|
| 1 | Skapa tillitsregler baserat på adressplanen enligt Zero Trust Architecture. Ta hänsyn till nätverkssegmentering, trafikstyrning, kryptering, nätverksresiliens, synlighet och analys, automatisering samt styrning. | AI föreslog att nätverket ska delas upp i segment och att åtkomst begränsas efter behov. Trafik bör styras och krypteras, nätverket ska kunna återhämta sig vid störningar och aktivitet bör övervakas. Åtgärder kan automatiseras och reglerna bör ses över regelbundet. | Jag behöver jämföra förslagen med adressplanen och kontrollera att segment, system och åtkomstbehov stämmer. Eftersom adressplanen inte ingick här kunde jag inte kontrollera några specifika adresser eller flöden. | Jag skulle ta bort eller ändra regler som inte stöds av adressplanen eller verksamhetens behov. Jag skulle också undvika att ange specifika IP-adresser eller portar utan underlag. | AI kan hjälpa till att strukturera förslag på tillitsregler, men reglerna måste anpassas och kontrolleras mot den faktiska adressplanen innan de används. |
### Egen reflektion

Jag använde AI som stöd för att strukturera ett förslag på tillitsregler utifrån Zero Trust-principer. AI:s svar behöver dock kontrolleras mot adressplanen och de faktiska behoven i nätverket. Jag kunde därför inte använda generella förslag som färdiga regler utan att först kontrollera och anpassa dem.


## Zonförslag
| Tillfälle | Fråga/prompt till AI | Sammanfattning av AI-svar | Vad kontrollerade du själv? | Vad ändrade eller valde du bort? | Slutsats med egna ord |
|---|---|---|---|---|---|
| 2 | Föreslå var zonerna DMZ, applikation, data, drift och klienter kan placeras i den angivna adressplanen för `10.40.0.0/16`. | En möjlig placering är klienter i `10.40.16.0/21` och drift/management i `10.40.29.0/24`, eftersom dessa nät redan har motsvarande syften. Applikations- och dataservrar kan placeras i `10.40.0.0/20`, men bör vid behov delas upp i mindre separata subnät. `10.40.128.0/17` är märkt som extern/integrationszon och kan vara en utgångspunkt för integrationssystem, men bör inte automatiskt betraktas som en DMZ. | Jag jämförde zonförslagen med syftena som redan anges i adressplanen. Jag behöver också kontrollera vilka system och trafikflöden som ska finnas i varje zon innan jag bestämmer exakta subnät. | Jag valde bort att behandla hela `10.40.128.0/17` som DMZ, eftersom det är ett mycket stort nät och adressplanen beskriver det som en extern/integrationszon. Jag angav inte heller exakta nya prefix för applikation och data utan mer information om behoven. | Adressplanen ger en grund för att placera klienter och drift, men applikationer, data och DMZ bör separeras tydligare innan reglerna fastställs. Zonernas placering behöver även stämma med vilka system som ska kommunicera med varandra. |

<<<<<<< HEAD
## Detektioner, Playbooks och Nedbrytning  
| Tillfälle | Fråga/prompt till AI | Sammanfattning av AI-svar | Vad kontrollerade du själv? | Vad ändrade eller valde du bort? | Slutsats med egna ord |
|---|---|---|---|---|---|
| 1. Nedbrytning av detektioner (D1, D2, D3) | Jag gav AI mallen och mina egna loggrader och mätningar och bad den hjälpa mig skriva ihop dem. | AI skrev utkastet i mallens form och räknade om mina antal till träffar per timme. | Jag gjorde själv alla sökningar och räknade träffarna i Discover (61 och 2 för D1, 0 för D2, 8 och 43 för D3). Jag valde rätt index och tid och kollade fältnamnen. | Jag rättade fel index och tidsfönster. Sådant jag inte mätt skrev jag inte in. | Brus ska mätas, inte gissas. Regel 5710 larmar för ofta, så 5712 är bättre. |
| 2. Playbooks D1, D2, D3 | Jag bad AI skriva ett utkast till playbooks med NIST:s fyra faser. | AI skrev utkast med faserna och när man ska eskalera eller avfärda. | Jag läste varje steg mot det jag själv sett i loggarna och kollade att faserna hålls isär. | Jag lät inte AI skriva "testad av" och datum. Det ska fyllas i av den som testar. | En playbook ska kunna följas av en främling, och varje avfärdande behöver ett skäl som går att kolla i loggen. |
| 3. Triagelogg | Jag bad AI formulera tre triageposter av mina loggrader. | AI delade upp dem i vad som hände, vad som berördes och vad som ska göras. | Jag kollade att observationen bara är det som står i loggen. Jag jämförde tiderna i D2 med `date` efter mitt eget test. | Jag tog bort sådant jag inte kunde bevisa. | Observation är det jag ser. Slutsats är det jag drar av det. De ska hållas isär. |
=======
>>>>>>> origin/main
