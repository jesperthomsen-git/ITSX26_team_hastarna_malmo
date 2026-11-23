Ö1. Vad går förlorat? Nämn tre saker som går förlorade när loggarna bara finns lokalt på
servern.

Svar: 
* Om servern kraschar kan loggarna försvinna
* Om någon får tillgång till servern kan personen ändra eller radera loggarna för att dölja sina spår
* Det blir svårare att jämföra händelser mellan flera servrar och se vad som faktiskt har hänt

Ö2. Läs en syslograd. Vad betyder varje del?
<38>1 2026-11-04T10:15:02.123+01:00 elev-07 sshd 1234 - - Accepted publickey
172.20.1.2 port 51234 ssh2

svar: 
<38> 38 / 8 = 4 auth
4 * 8 = 32
38 - 32 = 6 info
---
1 - RFC 5424
2026-11-04T10:15:02.123+01:00 - TIMESTAMP
elev-07 - HOSTNAME
sshd - APP-NAME
1234 – PROCID
- - MSGID
- - STRUCTURED DATA
Accepted publickey - MSG

Ö3. Räkna PRI. PRI = facility × 8 + severity. Vilken facility och severity har PRI 13, 86 och 166 (i
meddelandet skrivet inom vinkelparenteser först på raden)? Vilket PRI får local5.info (local5 =
21, info = 6)?

| PRI | Facility | Severity |
|---|---|---|
| 13 | 1 user | 5 notice |
| 86 | 10 authpriv | 6 info |
| 166 |	20 local4 |	6 info |

local5 
21 * 8 * 6 = 174


Ö4. RFC 3164 mot RFC 5424. Nämn två saker i tidsstämpeln som RFC 5424 har men RFC 3164 saknar, och varför de spelar roll när loggar från flera värdar ska läggas i ordning.

svar: årtal och tidszon. UTC som standard
det spelar stor roll för att kunna skapa en ordentlig tidlinje om när en händelse sker. Det blir svårt att avgöra om olika loggar får olika tider.

Ö5. Vad skyddar TLS? Vilka tre hot mot loggtrafiken skyddar TLS mot enligt RFC 5425? Nämn ett hot som TLS på transporten inte skyddar mot.

svar: 
* TLS skyddar loggen under transporten genom kryptering
* om någon försöker att manipulera loggen
* någon försöker att utge sig för att vara loggservern 

* skyddar inte vid före eller efter transport


Ö6. Journal och fil. Var lagras journald:s journal om /var/log/journal saknas, och vad händer då vid omstart? Varför finns samma sshd-händelse både i journalen och i /var/log/secure?

svar: Om /var/log/journal saknas och journald använder automatisk lagring sparas journalen i /run/log/journal tillfälligt i minnet. loggarna försvinner då det är temporärt. 

journald and rsyslog kan samla samma händelse i denna mappen

Ö7. Regeln för messages. Vad betyder *.info;mail.none;authpriv.none;cron.none /var/log/messages?

svar: 
*.info - allla faciliteter med info eller högre nivå
mail.none - inga mails
authpriv.none - inga privata auth.loggar
cron.none - ta inte med cron loggar
/var/log/messages - destinationen av loggen

Ö8. Kö. Vad är skillnaden mellan en minneskö och en diskstödd kö i rsyslog, och vilken parameter gör kön diskstödd? Vad gör action.resumeRetryCount="-1"?

minneskö ligger i minnet
diskstödd sparar det på disken genom queue.type=filename
action.resumeRetryCount="-1" gör att rsyslog fortsätter försöka skicka loggar

Ö9. uid, euid och auid. Du loggar in som student och kör sudo cat /etc/shadow. Vilka värden får uid, euid och auid i auditposten, och vilket av dem gör att det går att se vem som körde kommandot?

svar: genom grep -E 'uid=| euid=| auid=' kunde jag hittade uid=root och euid=root auid=student
root=0
id i terminalen ger mig 1000 på student

Ö10. Fråga eller beställning? Vilka av följande är frågor som kan styra ett urval, och vilka är beställningar av en loggkälla? Skriv om beställningarna till frågor.

1. "Vi vill ha brandväggsloggen."
svar: Beställningar - vilka anslutningsförsök har blockerats av brandväggen på elev-07 under det senaste dygnet, och från vilka IP-adresser kom de?

2. "Vem loggade in som root på elev-07 mellan kl 02 och 04 natten till 5 november?"
svar: fråga - tidspann, ämne: root & elev, fastställa vem loggade in

3. "Spara allt från sshd."
svar: Vilka misslyckade SSH-inloggningar har skett på elev-43 under det senaste dygnet, och vilka användare och IP-adresser var inblandade?

4. "När blockerades senast ett försök att nå loggservern på port 6514 från webbzonen?"
svar: fråga - frågan hjälper oss att välja rätt logg som är brandväggsloggen.

