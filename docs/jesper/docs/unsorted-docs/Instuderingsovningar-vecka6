#Ö1. Decoder och regel.
Vad gör en decoder, och vad gör en regel? Varför kan en regel inte
matcha på ett fält som decodern inte har plockat ut?

Svar: Decoder visar källan som srcip, srcuser. Regel är en template som är förskapad baserad på Mitre och Wazuhs regler. Efter det har du möjlighet att skapa alarm/regler runt hur dem ska fungera genom avgränsningar.

# Ö2. Nivåer.
Ett larm på nivå 3 – bryr du dig? Ge ett exempel där nivå 3 är ointressant ensamt
men viktigt som del av en kedja.

Svar: Ett nivå 3 larm är ganska ointressant och kan skapa en dålig vana att inte kolla på varningarna. Genom filtrering kan man kontrollera med specifikt vart, vem och vad som gjordes. Kanske en brandväggs ändring från en användare som inte har varit inloggad på 30 dagar?

#Ö3. Vilket fält?
Para ihop syslog-fälten (tidsstämpel, hostname, app-name, severity, message) med vad de svarar på: när, vilken värd, vilken tjänst, hur allvarligt, vad hände.

Svar: 
Tidstämpel: svarar på när
hostname: svarar på vem
app-name: svarar på tjänst
severity: svarar på hur allvarligt
message: svarar på vad som hände genom custom kommentar

# Ö4. Sanningstabellen.
Förklara skillnaden mellan ett falskt positivt och ett falskt negativt larm.
Vilket är farligast i en SOC, och varför?

Svar: 
Falskt positiv: Larmet är uppsatt men avgränsningen är för bred och blir brus
Falskt negativ: Verkligt hot kommer in utan uppsatt larm som kan larma för den.


# Ö5. Brute force.
Beskriv i ord vilka observationer i loggen som skiljer ett brute force-försök från
en enstaka feltryckning. Vilka fält och vilket mönster (antal, tid, samma källa) bygger
detektionen på?

Svar: Detektionen bygger på händelser per minut, om en kollega skriver fel lösenord 3-5 gånger för att dem skriver för snabbt är mänskligt, 12 felaktiga inloggningar från samma källa under 2 minuter är misstänksamt. Observation är inte samma sak om beslut eller slutgiltigt svar. I wazuh finns det förinställda regler man kan använda sig utav som 5712 som kan hitta mönster och larmar när den hittar samma sak flera gånger som käll address som exempel.

# Ö6. Brusmätning.
Din regel ger 48 träffar i normaltrafikperioden, som är 24 timmar lång. Hur
många träffar per dygn är det? Om din larmtröskel är "5 per timme" – hur många larm blir det
per dygn i normaltrafik, ungefär?

Svar: 48 träffar på normal trafik.  Antingen så är det 5 larm per timme av 48 träffar under 24 timmar som är ca 9-10 larm eller är det 5 larm var timme i 24 timmar som ger 120 larm under en dag.


# Ö7. Detektion vs testkörning.
Varför blir en regel som skrivs mot din egen testinloggning
antingen extremt smal eller extremt bred när riktig trafik börjar flöda? Hur undviker du det?

Svar: En regel som kan vara allt för smal kan vara kopplad till en specifik address eller port som gör att larm inte larmar för annat intrång än det som är specificerat. En för bred kan skapa brus och oavsiktligen göra attackeraren näst intill osynlig. Detta kan hindras när man kollar på vad som är normalt i nät trafiken/loggen och sedan skapa playbooks och regler för alarm utifrån flödet. Som ett flödesschema. 

# Ö8. Triage. Ett larm går.
Skriv de tre frågor du besvarar i triagen, och en observation (inte en slutsats) du skulle leta efter för var och en.

Svar:
Vad har hänt? Vad tror du hände? (regel, källa, tid)
Vad har berörts? Vad kan ses? (servers, tjänster, konton)
vad ska göras? Skall det ignoreras, eskaleras, ändra avgränsning eller blockera källan?

# Ö9. Avfärda.
Vad skiljer ett granskbart avfärdandeskäl från ett som bara är påstått? Skriv ett
exempel på vardera för ett larm du själv orsakat.

svar: Ett granskbart skäl är när man kan knyta det till fakta. jag skickar ett nmap commando mot min egna server och kan sedan få fram loggen där loggen visar tiden där jag utförde kommandot.

Ett påstående är att säga att det var jag utan direkt fakta som backar dig.g

# Ö10. Playbook och faser.
Nämn incidenthanteringens fyra faser (NIST 800-61). Ge ett playbook-
steg som hör till en annan fas än analys

# Playbook
Förberedelse – skapa rutiner, roller och verktyg för incidenthantering.

Upptäckt och analys – upptäck möjliga incidenter och bedöm omfattning och allvar.

Begränsning, utrotning och återställning – begränsa skadan, ta bort hotet och återställ systemen.

efterarbete - vad kan förbättras? CIS controls? Behöver något återställas efter föregående kontroll?

