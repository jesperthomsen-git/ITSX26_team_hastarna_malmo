# Playbooks och triagelogg – Team 4 Hästarna (D1, D2, D3 och D4)

---

# Playbook D1 – Brute force mot SSH

**Monitor:** `Brute force SSH elev-10 (T1110)` (regel 5710/5712, se nedbrytning, händelse 1)
**Testad av:** (elev-10) · **Datum:** (11/11-2026)

## 1. Förberedelse
- Monitorn är Enabled och vi vet hur ofta den normalt larmar (5710 cirka 115 per timme, 5712 cirka 4 per timme i normaltrafik, mätt 11 nov 08:05-08:37).
- Vi har adressplanen till hands, så vi kan se vilken zon en källadress tillhör och om den är en känd källa (till exempel ctf-servern 172.20.1.10 vid övningar).
- Åtkomst till Discover (`wazuh-alerts-*`) och till servern via jump. Vi vet vem i teamet som triagerar och vem som får blockera.

## 2. Upptäckt och analys
1. Anteckna tid, `rule.id`, server (`location`), `data.srcip` och `data.srcuser` från larmet. Skriv bara det som står i loggen.
2. Räkna hur många försök och under hur lång tid (Discover, samma `data.srcip`).
3. **Sök utan serverfilter** (`data.srcip: <IP>`): träffar samma adress fler servrar?
4. Sök efter lyckad inloggning från samma adress (`rule.id: 5715` och samma `data.srcip`) efter försöken.
5. Jämför adressen mot adressplanen och mot kända tester (chattmeddelande med tid).

**Eskalera (till Peter/teamets ansvarige) om något av detta stämmer:**
- en lyckad inloggning från samma adress efter misslyckade försök,
- samma adress träffar flera servrar,
- adressen finns inte i adressplanen och är inte en känd källa,
- en ny användare eller ett root-kommando syns efter försöken (D3).

**Avfärda som falsklarm/legitimt om allt detta stämmer:**
- adressen är en känd testkälla eller ligger i en zon där sådan trafik förväntas (adressplanen, eller chattmeddelande med tidsstämpel),
- ingen lyckad inloggning från adressen,
- loggen kommer från normaltrafiken (`normal.log`).
Skriv alltid ett skäl som någon annan kan kontrollera (sökning, adress, tidsstämplat meddelande).

## 3. Begränsning, utrotning och återställning
- **Begränsa:** blockera adressen i paketfiltret (nftables) och i molnbrandväggen. Lås kontot om det fanns en lyckad inloggning.
- **Utrota:** vid lyckad inloggning: byt lösenord/nycklar, leta efter nya användare (`last`, `sudo ausearch`), avsluta okända sessioner.
- **Återställ:** ta bort blockeringen först när hotet är borta, och kontrollera att tjänsten fungerar (SSH från jump).

## 4. Aktiviteter efter incidenten
- Skriv en post i triageloggen (observation och slutsats i olika fält).
- Justera monitorn om den larmade för ofta eller missade något (tröskel, tidsfönster).
- Uppdatera brus och falsklarmsrisk i nedbrytningen. Anteckna vad vi lärde oss.

---

# Playbook D2 – Zonöverträdelse (blockerad utgående trafik)

**Monitor:** `Zonöverträdelse elev-10 (ZON-UT-DROP)` (se nedbrytning, händelse 2)
**Testad av:** (elev-10) · **Datum:** (11/11-2026)

## 1. Förberedelse
- Monitorn söker i `wazuh-archives-*` på `data.action: "ZON-UT-DROP"` för vår server. Mätt 9-11 nov: 0 träffar i normaltrafik (0,53 timmar) och 4 träffar på 50 timmar, alla våra egna tester.
- Uppdatering 16 nov: efter 11 nov syns fler stoppade anslutningar. En stor topp den 12 nov och mindre toppar varje dag därefter. De senaste raderna visar att elev-10 själv får utgående trafik till 172.20.1.142 på port 80 stoppad. Därför ska träffmängden mätas om innan falsklarmsrisken anses vara låg.
- Vi har flödestabellen (D1-D7) och adressplanen, så vi kan se vad som är tillåtet.
- Åtkomst till servern för att kontrollera processer och `audit.log`.

## 2. Upptäckt och analys
1. Anteckna tid, `data.srcip`, `data.dstip`, `data.dstport` och protokoll.
2. **Sök utan serverfilter** (`data.action: "ZON-UT-DROP"`): försöker andra servrar samma mål?
3. Kolla vad som försökte ansluta: på servern, `sudo ausearch -ts recent -i` och `ss -tp`, och leta efter program och konto.
4. Upprepas det med jämna mellanrum mot samma mål? (jämför med U6.5, ATT&CK T1071.001)
5. Jämför målet med flödestabellen: saknas det ett flöde som borde finnas?

**Eskalera om något av detta stämmer:**
- upprepade försök mot samma okända externa mål, särskilt med jämna mellanrum (beaconing),
- ett okänt program eller ett tjänstekonto försöker nå internet,
- det sker tillsammans med ett root-kommando (D3) eller en misstänkt inloggning (D1).

**Avfärda om allt detta stämmer:**
- det är ett känt test (till exempel `timeout 3 bash -c 'echo > /dev/tcp/...'` med tidsstämpel i chatten eller terminalen),
- eller en känd tjänst som saknar en regel i flödestabellen (då är det en ändring i regelverket, inte en incident).
Skriv alltid ett skäl som någon annan kan kontrollera.

## 3. Begränsning, utrotning och återställning
- **Begränsa:** trafiken är redan stoppad av paketfiltret. Behåll blockeringen. Stoppa programmet eller tjänsten som försökte (`systemctl stop <tjänst>`), och lås kontot vid misstanke.
- **Utrota:** ta bort det som startade anslutningen (okänt program, cron-jobb, tjänst) och kontrollera nya användare och uppgifter.
- **Återställ:** om det var en legitim tjänst: lägg till ett flöde i flödestabellen med motivering, testa, och verifiera att larmet slutar.

## 4. Aktiviteter efter incidenten
- Skriv en post i triageloggen.
- Uppdatera flödestabellen eller monitorn om det behövs. Notera brus och falsklarmsrisk i nedbrytningen.
- Skriv vad vi lärde oss (till exempel vilket program försökte och varför).

---

# Playbook D3 – Kommando som körs som root (sudo)

**Monitor:** `T1548-Sudo and Sudo Caching elev-43` (regel 5402, se nedbrytning, händelse 3)
**Testad av:** (elev-43) · **Datum:** (11/11-2026)

## 1. Förberedelse
- Monitorn är Enabled, tidsramen är 5 minuter och triggern är IS ABOVE 0.
- Vi vet hur ofta den normalt larmar: cirka 15 larm per timme i normaltrafik (8 larm på 32 minuter, mätt 11 nov 08:05-08:37), nästan alla läsande kommandon från student.
- Vi vet vilka konton som får använda sudo (student har `(ALL) ALL`) och vilka kommandon som är normalt arbete.
- Åtkomst till Discover och till servern via jump. Vi vet vem som triagerar.

## 2. Upptäckt och analys
1. Anteckna tid, server (`location`), vem som körde (`data.srcuser`), som vem (`data.dstuser`) och kommandot (`data.command`). Skriv bara det som står i loggen.
2. Titta på vad kommandot gör: ett läsande eller känt administrationskommando (till exempel `nft list ruleset`, `tail -n 50 /var/log/secure`, `dnf`, `systemctl status`) eller något oväntat (till exempel `useradd`, `chmod`, `rm`, `systemctl stop`, `nmap`).
3. **Sök utan serverfilter** (`rule.id: 5402 and data.srcuser: <konto>`): gör samma konto sudo på flera servrar?
4. Titta på vad som hände före och efter: misslyckade eller ovanliga inloggningar (D1, regel 5712 och 5715) och stoppad utgående trafik (D2) från samma server.

**Eskalera om något av detta stämmer:**
- kommandot ändrar användare, rättigheter eller loggar (`useradd`, `chmod`, `rm` på loggfiler, `systemctl stop rsyslog`/`auditd`),
- kommandot skannar eller undersöker nätet (till exempel `nmap`) och ingen i teamet har sagt att det är ett test,
- sudo sker direkt efter en misslyckad eller ovanlig inloggning,
- kontot är inte ett konto som ska använda sudo,
- samma konto gör ovanliga kommandon på flera servrar.

**Avfärda om allt detta stämmer:**
- kommandot är ett läsande eller känt administrationskommando,
- det körs av ett konto som får använda sudo, från en vanlig terminal (`data.tty: pts/0`),
- det går att kontrollera (teamets chatt med tidsstämpel, eller att kommandot ingår i en känd uppgift, till exempel att ladda `zon.nft`).
Skriv alltid ett skäl som någon annan kan kontrollera.

## 3. Begränsning, utrotning och återställning
- **Begränsa:** lås kontot eller ta bort sudo-rättigheten om det är misstänkt. Avsluta pågående sessioner.
- **Utrota:** kontrollera ändringar som kommandot gjort (nya användare, ändrade filer, stoppade tjänster) och återställ dem.
- **Återställ:** kontrollera att `rsyslog` och `auditd` körs och att loggar fortfarande skickas till loggservern.

## 4. Aktiviteter efter incidenten
- Skriv en post i triageloggen.
- Justera monitorn eller undanta kända läsande kommandon om den larmar för ofta. Anteckna vad vi lärde oss.

---

# Playbook D4 – Datastöld (exfiltration), FIKTIV

> **FIKTIV playbook.** Vi har inget bevis för att larmet fungerar. Ingen monitor på regeln är byggd eller testad, och brus är inte mätt. Playbooken visar hur vi skulle hantera händelsen. Den ska inte tas som verifierad detektion.

**Antagen regel:** `rule.mitre.id: "T1041"` (Exfiltration Over C2 Channel), index `wazuh-alerts-*`. Det är ett antagande: vi har inte sett att någon regel med det id:t larmar hos oss.
**Monitor:** finns inte (ej byggd, ej testad).
**Brus och falsklarmsrisk:** ej mätt.
**Skriven av:** Stefan · **Testad av:** ej testad · **Datum:** ej testad

## 1. Förberedelse
- Vi vet att detektionen är ett antagande, och att den ska mätas och testas innan den litas på.
- Vi har flödestabellen och adressplanen, så vi kan se vilka externa mål som är tillåtna.
- Åtkomst till Discover (`wazuh-alerts-*` och `wazuh-archives-*`) och till servern via jump. Vi vet vem som triagerar och vem som får blockera.

## 2. Upptäckt och analys
1. Anteckna tid, `rule.id`, server (`location`), program/konto och mål (`dstip`) från larmet. Skriv bara det som står i loggen.
2. Räkna hur mycket och hur ofta: en stor överföring, eller upprepade små med jämna mellanrum (jämför med U6.5)?
3. **Sök utan serverfilter:** går samma mål från flera servrar?
4. Är målet känt? Jämför mot flödestabellen och adressplanen. Är kontot ett tjänstekonto som borde göra detta (till exempel backup)?
5. Finns det tecken på intrång före: misslyckade inloggningar (D1), root-kommando (D3) eller blockerad utgående trafik (D2)?

**Eskalera om något av detta stämmer:**
- målet är okänt och står inte i flödestabellen,
- ett tjänstekonto eller okänt program laddar upp data,
- det sker med jämna mellanrum eller i stor mängd,
- det sker tillsammans med D1, D2 eller D3.

**Avfärda om allt detta stämmer:**
- målet är känt och tillåtet (står i flödestabellen),
- programmet och kontot är avsedda för detta (till exempel en dokumenterad backup),
- någon kan bekräfta det med ett skäl som går att kontrollera.

## 3. Begränsning, utrotning och återställning
- **Begränsa:** blockera målet i paketfiltret och molnbrandväggen. Stoppa programmet (`systemctl stop <tjänst>`). Isolera servern vid misstänkt stöld.
- **Utrota:** ta bort det som startade överföringen (okänt program, cron-jobb, tjänst). Byt nycklar och lösenord som kan vara läckta. Leta efter nya användare.
- **Återställ:** återinför tjänsten först när orsaken är borta. Kontrollera vad som skickats och bedöm vilken data som berörs.

## 4. Aktiviteter efter incidenten
- Skriv en post i triageloggen.
- Bygg och mät en riktig monitor, och uppdatera nedbrytningen med brus och falsklarmsrisk.
- Skriv vad vi lärde oss.

---

# Triagelogg

## Post 1 – D1 Brute force (normaltrafik)

```
ID:             T-D1-1
Tid:            2026-11-11 08:24 svensk tid (07:24 UTC)
Monitor/regel:  Brute force SSH elev-10 (T1110), rule.id 5710 (nivå 5)
Agent/källa:    /var/log/remote/inmatat/elev-10/normal.log (server elev-10)

OBSERVATION (only what's in the log, no interpretation)
Source IP:      10.40.2.8
User:           postgres, deploy med flera
Number of events and time span:
                Regel 5710 gav 61 larm på elev-10 under 08:05-08:37 svensk tid
                (11 nov). 11 av dem kom från 10.40.2.8, inom cirka 1 sekund
                (08:24:50) och med olika användarnamn.
Relevant log line(s):
                elev-10 sshd[60851]: Invalid user postgres from 10.40.2.8 port 54428
Search without host filter (query + result):
                rule.id: 5710 and data.srcip: 10.40.2.8  ->  11 träffar, alla på elev-10.

SLUTSATS
Vad hände:      Försök att logga in med konton som inte finns (postgres, deploy med flera)
                från 10.40.2.8, tätt i tid.
Vad berördes:   elev-10, SSH-tjänsten. Inget konto (kontona finns inte).
Bedömning:      Falsklarm (normaltrafik)
Skäl:           Loggen ligger i normal.log (normaltrafik). Adressen 10.40.2.8 ligger i
                Applikationszonen 10.40.2.0/23 enligt adressplanen (inget namngivet
                system på just .8). Ingen lyckad inloggning från adressen
                (rule.id: 5715 and data.srcip: 10.40.2.8 -> 0 träffar).

```

## Post 2 – D2 Zonöverträdelse

```
ID:             T-D2-1
Tid:            2026-11-11 10:36 svensk tid (09:36:08 UTC)
Monitor/regel:  Zonöverträdelse elev-10 (ZON-UT-DROP), data.action ZON-UT-DROP
Agent/källa:    /var/log/remote/elev-10/syslog.log (server elev-10)

OBSERVATION (only what's in the log, no interpretation)
Source IP:      91.99.158.191
User:           (framgår inte av loggraden)
Number of events and time span:
                2 poster, 09:36:08 och 09:36:09 UTC (1 sekund)
Relevant log line(s):
                elev-10 kernel: ZON-UT-DROP IN= OUT=eth0 SRC=91.99.158.191 DST=1.1.1.1
                PROTO=TCP SPT=46828 DPT=8080 ... SYN
Search without host filter (query + result):
                data.action: "ZON-UT-DROP" (9 nov 08:05 till 16 nov 09:11, wazuh-archives-*)
                ->  7 878 träffar totalt (alla servrar), med en stor topp den 12 nov.

SLUTSATS
Vad hände:      Servern försökte ansluta utåt till 1.1.1.1 på port 8080. Paketfiltret stoppade det.
Vad berördes:   elev-10, utgående trafik. Inget konto eller tjänst skadades.
Bedömning:      Legitimt (eget test)
Skäl:           Ett eget test kördes på servern: `timeout 3 bash -c 'echo > /dev/tcp/1.1.1.1/8080'`.
                `date` direkt efter visade 09:36:11 UTC. Tiden stämmer med loggraderna
                (09:36:08 och 09:36:09). Kontrollera: data.dstip: 1.1.1.1 and data.dstport: 8080 i Discover.

```

## Post 3 – D3 Kommando som körs som root (sudo)

```
ID:             T-D3-1
Tid:            2026-11-16 07:06 svensk tid (06:06:15 UTC)
Monitor/regel:  T1548-Sudo and Sudo Caching elev-43, rule.id 5402 (nivå 3)
Agent/källa:    sudo-raderna i secure på elev-43

OBSERVATION (only what's in the log, no interpretation)
Source IP:      (ingen, lokal terminal pts/0)
User:           student, som root (data.dstuser: root)
Number of events and time span:
                2 poster inom cirka 30 sekunder (06:06:15 och 06:06:43 UTC)
Relevant log line(s):
                sudo: student : TTY=pts/0 ; PWD=/home/student ; USER=root ;
                COMMAND=/sbin/nft -f /etc/nftables/zon.nft
                sudo: student : TTY=pts/0 ; PWD=/home/student ; USER=root ;
                COMMAND=/sbin/nft list ruleset
Search without host filter (query + result):
                rule.id: 5402 and data.srcuser: student (Last 7 days)  ->  170 träffar,
                varav 43 på elev-43. Resten kommer från andra servrar.

SLUTSATS
Vad hände:      Kontot student körde med sudo först ett kommando som läser in
                regelfilen zon.nft i brandväggen, och därefter ett kommando som listar reglerna.
Vad berördes:   elev-43, paketfiltret (nftables). Ingen ny användare eller ändrad loggfil syns.
Bedömning:      Legitimt (administrationsarbete)
Skäl:           Kommandona gäller teamets egen regelfil (/etc/nftables/zon.nft, finns i repot)
                och körs interaktivt från student (har sudo enligt skyddsbeskrivningen),
                direkt efter varandra: ladda regler, kontrollera dem. Jesper (elev-43) kan
                bekräfta att det var han vid den tiden.  

```

## Triagepost T-D4-1 (FIKTIVT EXEMPEL, inte från en riktig logg)

```

- **ID:** T-D4-1
- **Tid:** ej från riktig logg (övningsexempel)
- **Monitor/regel:** antagen regel `rule.mitre.id: "T1041"` (ej testad)
- **Agent/källa:** ej från riktig logg

**OBSERVATION** (bara det som står i loggen, ingen tolkning)
- **Source IP:** (exempel) intern server
- **User:** (exempel) tjänstekonto
- **Antal händelser och tid:** (exempel) upprepade uppladdningar med jämna mellanrum
- **Relevant loggrad:** ingen riktig loggrad, posten är en övning
- **Sökning utan serverfilter:** `rule.mitre.id: "T1041"` -> ej körd

**SLUTSATS**
- **Vad hände:** fiktivt, ett tjänstekonto skickar data till ett externt mål.
- **Vad berördes:** (exempel) servern och den data som skickats.
- **Bedömning:** skulle eskaleras om målet är okänt. Kan inte bedömas utan riktig logg.
- **Skäl:** inget granskbart skäl ännu, eftersom larmet inte är bevisat.
- **Vad ska göras:** bygg och mät en monitor, testa den, och gör sedan om triagen med riktiga data.  

```