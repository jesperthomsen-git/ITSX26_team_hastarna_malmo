# Playbooks och triagelogg – Team 4 Hästarna (D1, D2, D3 och D4)

---

# Playbook D1 – Brute force mot SSH

**Monitor:** `Brute force SSH elev-10 (T1110)` (regel 5710/5712, se nedbrytning, händelse 1)
**Testad av:** (elev-10) · **Datum:** (09/11-2026)

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
**Testad av:** (elev-10) · **Datum:** (09/11-2026)

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
Vad ska göras:  Inget. Regel 5710 ensam ger för mycket brus, så monitorn använder 5712.
```

## Post 2 – D2 Zonöverträdelse (eget test)

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
Vad ska göras:  Inget för den här posten. Stoppade anslutningar efter 11 nov ska triageras
                separat (se D2-playbooken, Förberedelse).
```

