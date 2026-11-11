# Skyddsbeskrivning – elev-10  

## 1. Lokalt: vem kan ändra eller radera loggen?  

Lokalt: Loggfilerna (messages, secure, audit.log) ägs av root och har rättigheterna -rw-------, så vanliga användare kan inte läsa dem. Men student har (ALL) ALL i sudo och kan därför läsa, ändra och radera dem. lsattr visar inga extra skydd (ingen a eller i). Det är som ett låst skåp där jag har huvudnyckeln: den som tar över mitt konto kan ändra det som hänt. En lokal logg räcker därför inte som bevis.  

## 2. Centralt: vem kan ändra eller radera loggen?  

Centralt: Jag har ingen inloggning på loggservern, så vitt jag vet. Jag kan bara två saker: skicka loggar dit (krypterat med TLS) och söka i dem med loggsök på jump.

loggsök kan bara söka. Det visar max 50 rader, och enligt kommentaren i skriptet bara från min egen server. På jump har jag bara en root-rättighet, ctf-klient. Vad det programmet får göra har jag inte kollat.

Det är bättre med central logg. Om någon tar över min server och tömmer /var/log har loggarna redan kommit fram till loggservern. Det är som att receptionisten har en kopia av loggboken på ett annat hotell, så det går inte att riva bort bevisen från båda.

Det jag inte kan bevisa är vem som sköter loggservern och om de kan ändra där.  

## 3. Lagringstid och rotation  

Lokalt: De vanliga loggarna (messages och secure) byts ut varje vecka, och de 4 senaste gamla filerna sparas. Det är alltså ungefär en månad tillbaka. Audit-loggen byts på storlek: varje fil är 8 MB och 5 filer sparas, sen tas den äldsta bort. Journalen sparas inte på disk (/var/log/journal finns inte), så den försvinner när servern startas om.

Vad det betyder för bevis: Gamla loggar raderas av sig själva. Upptäcker man en incident efter mer än en månad kan bevisen redan vara borta lokalt. Det är som en loggbok som slängs efter fyra veckor. Därför är det bra att loggarna också finns centralt.  

## 4. Onåbar mottagare  

Om loggservern inte går att nå ska loggarna ligga kvar i en kö på min server, och rsyslog försöker skicka dem igen och igen (resumeRetryCount="-1" betyder att den aldrig ger upp). Det är som att receptionisten lägger kopiorna av loggboken i en låda tills vägen till det andra hotellet öppnas igen.

Kön kan flytta över till disk (queue.filename="fwd_tls"), och med saveOnShutdown="on" sparas innehållet även om rsyslog startas om. Köfilerna hamnar i en mapp som ägs av root, så den som har root kan också radera dem.

Enligt rsyslogs standard rymmer kön 1000 meddelanden i minnet och går över till disk vid 90 %. Jag har inte satt någon gräns för hur mycket disk den får använda. Om ett meddelande inte hinner in i kön på 2 sekunder kastas det.

Belägg: raden ur 60-brandvagg.conf (grep -n queue) och ls -l /var/lib/rsyslog. Det finns inga fwd_tls-filer nu, eftersom loggservern är nåbar och kön är tom.  

## Belägg och bevisförstöringsscenario  

Scenario: Någon tar över kontot student på min server. Eftersom student har (ALL) ALL i sudo blir personen root och kan försöka dölja vad som hänt. Det är som att någon stjäl huvudnyckeln och river ur sidor ur loggboken.

Vad personen kan göra: tömma messages, secure och audit.log, stoppa rsyslog eller auditd, och radera köfilerna. Inget skyddar filerna (lsattr visar bara e).

Vad som ändå finns kvar: loggar som redan skickats till loggservern. Jag hittar dem med loggsök, till exempel sudo-raderna med auid=1000, som visar vem som körde kommandot. Så vitt jag vet kommer personen inte åt loggservern från min server.

Vad som kan försvinna: loggar som inte hunnit skickas, det som bara låg i journalen och allt efter att loggningen stängts av.

Förslag (inte testat): begränsa sudo, använda chattr +a på loggfilerna och larma om min server slutar skicka loggar.

Belägg: ls -l, lsattr, sudo -l och loggsök.  