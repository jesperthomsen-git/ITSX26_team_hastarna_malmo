# Detektioner – Team 4 Hästarna

Playbooks och triagelogg finns i `playbooks-triagelogg.md`.

## Sammanfattning

| Nr | Detektion | Monitor | Ägare | ATT&CK | Normaltrafik 08:05-08:37 (0,53 h) | Träffar per timme | Falsklarmsrisk |
|---|---|---|---|---|---|---|---|
| D1 | Brute force mot SSH | `Brute force SSH elev-10 (T1110)` | elev-10 | T1110 | 5710: 61 larm. 5712: 2 larm | 5710: cirka 115. 5712: cirka 4 | Hög för 5710, lägre för 5712 |
| D2 | Zonöverträdelse (blockerad utgående trafik) | `Zonöverträdelse elev-10 (ZON-UT-DROP)` | elev-10 | (se nedbrytningen) | 0 larm | 0 | Låg i normaltrafik 9-11 nov, behöver mätas om efter 11 nov |
| D3 | Kommando som körs som root (sudo) | `T1548-Sudo and Sudo Caching elev-43` | elev-43 | T1548.003 | 8 larm | cirka 15 | Medelhög till hög |
| D4 | (teamets egen händelse) | | | | | | |

---

## Händelse 1: Brute force mot SSH

| Del | Svar |
|---|---|
| Loggkälla | sshd-loggen från elev-10 som loggservern tar emot: `/var/log/remote/inmatat/elev-10/normal.log` |
| Fält vi använder | `rule.id`, `location`, `data.srcip`, `data.srcuser` |
| Riktiga värden | `rule.id: 5710`, `rule.level: 5`, `location: /var/log/remote/inmatat/elev-10/normal.log`, `data.srcip: 10.40.2.8`, `data.srcuser: postgres`, `agent.name: log`, MITRE T1110.001 |
| Exempel ur full_log | `sshd[60851]: Invalid user postgres from 10.40.2.8 port 54428` |
| Detektionens fråga | `rule.id: (5710 or 5712) and location: *elev-10*` |
| Gränsfall som inte ska träffa | Ett enstaka misslyckat inloggningsförsök är ingen brute force. Regel 5710 larmar vid varje försök med okänt konto och ger därför mycket brus. Brute force är många försök i rad från samma adress (regel 5712). |
| Brus i normaltrafik (2026-11-11 08:05-08:37) | 5710: 61 larm. 5712: 2 larm (elev-10). |
| Fönstrets längd | 32 minuter = 0,53 timmar |
| Träffar per timme | 5710: cirka 115 per timme. 5712: cirka 4 per timme. |
| Falsklarmsrisk | Hög för 5710: 61 larm på 32 minuter är för mycket brus, eftersom den larmar vid varje försök med okänt konto. Lägre för 5712 (2 larm), men även den kan vara falsklarm om en användare eller ett skript misslyckas flera gånger i rad utan att det är ett angrepp. |

---

## Händelse 2: Zonöverträdelse (blockerad utgående trafik)

| Del | Svar |
|---|---|
| Loggkälla | Brandväggens (nftables) loggrad från kärnan på elev-10, som loggservern tar emot: `/var/log/remote/elev-10/syslog.log` (index `wazuh-archives-*`, standardregler skapar inget larm) |
| Fält vi använder | `data.action`, `location`, `data.dstip`, `data.dstport`, `data.srcip` |
| Riktiga värden | `data.action: ZON-UT-DROP`, `decoder.name: kernel`, `location: /var/log/remote/elev-10/syslog.log`, `data.srcip: 91.99.158.191`, `data.dstip: 1.1.1.1`, `data.dstport: 8080`, `data.protocol: TCP`, `agent.name: log` |
| Exempel ur full_log | `elev-10 kernel: ZON-UT-DROP IN= OUT=eth0 SRC=91.99.158.191 DST=1.1.1.1 ... PROTO=TCP SPT=46828 DPT=8080 ... SYN` |
| Detektionens fråga | `data.action: "ZON-UT-DROP" and location: *elev-10*` |
| Gränsfall som inte ska träffa | Tillåten utgående trafik, till exempel NTP (tidssynk) till 213.239.239.164, loggas inte med `ZON-UT-DROP` och ska inte larma. Regeln bygger på prefixet (blockerad trafik), inte på testets mål 1.1.1.1 eller port 8080. |
| Brus i normaltrafik (2026-11-11 08:05-08:37) | 0 träffar |
| Fönstrets längd (normaltrafik) | 32 minuter = 0,53 timmar |
| Träffar per timme | 0 per timme |
| Brus i hela verifierade fönstret | 4 träffar på 50 timmar (9 nov 09:00 till 11 nov 11:00), alltså cirka 0,08 per timme. Alla fyra var egna tester med `/dev/tcp` mot 1.1.1.1:8080 (två vid omstartstestet 9 nov och två den 11 nov kl 10:36). Brandväggen stoppade ingen annan trafik. |
| Efter 11 nov | Fler stoppade anslutningar syns, med en stor topp den 12 nov och mindre toppar därefter. Senast 16 nov 08:57-08:58 stoppades trafik från elev-10 till 172.20.1.142 port 80, samma minut som ett `sudo nmap 172.20.1.142` loggades. Orsaken behöver bekräftas av teamet, och träffmängden mätas om. |
| Falsklarmsrisk | Låg i normaltrafik (0 träffar på 32 minuter), så varje träff är värd att titta på. Falsklarm uppstår om en tjänst försöker nå något som flödestabellen saknar, till exempel en ny uppdateringsserver, eller om vi själva testar (`/dev/tcp`, skanning). |

---

## Händelse 3: Kommando som körs som root (sudo)

Detektionen ägs av elev-43 (Jesper).

| Del | Svar |
|---|---|
| Loggkälla | sudo-raderna i `secure` på elev-43 (och auditd-regeln för root-kommandon från vecka 5), som loggservern tar emot. Wazuh skapar larmet i `wazuh-alerts-*`. |
| Fält vi använder | `rule.id`, `location`, `data.srcuser`, `data.dstuser`, `data.command`, `data.tty`, `data.pwd` |
| Riktiga värden | `rule.id: 5402`, `rule.level: 3`, `rule.description: Successful sudo to ROOT executed`, `rule.mitre.technique: Sudo and Sudo Caching`, `data.srcuser: student`, `data.dstuser: root`, `data.tty: pts/0`, `data.pwd: /home/student`, `data.command: /sbin/nft list ruleset`, `predecoder.program_name: sudo`, `agent.name: log` |
| Exempel ur full_log | `sudo: student : TTY=pts/0 ; PWD=/home/student ; USER=root ; COMMAND=/sbin/nft list ruleset` |
| Detektionens fråga | `rule.id: 5402 and location: *elev-43*` |
| Monitor | `T1548-Sudo and Sudo Caching elev-43`, Per query monitor, index `wazuh-alerts-*`, schema 1 minut, tid senaste 5 minuterna, trigger IS ABOVE 0 |
| ATT&CK-teknik | T1548 (Abuse Elevation Control Mechanism), sub-teknik T1548.003 Sudo and Sudo Caching |
| Gränsfall som inte ska träffa | Ett kommando som körs utan sudo (vanlig användare) ska inte träffa, inte heller sudo till ett annat konto än root (`data.dstuser` är inte root). Vanligt administrationsarbete träffar däremot (till exempel `nft list ruleset` eller `tail -n 50 /var/log/secure`) och är normalt. Det intressanta är oväntade kommandon. |
| Brus i normaltrafik (2026-11-11 08:05-08:37) | 8 larm |
| Fönstrets längd (normaltrafik) | 32 minuter = 0,53 timmar |
| Träffar per timme (normaltrafik) | cirka 15 per timme (8 / 0,53) |
| Brus i hela verifierade fönstret | 43 larm på elev-43 under 168 timmar (9-16 nov, Discover, Last 1 week), alltså cirka 0,26 per timme i genomsnitt. Larmen kommer i omgångar när någon arbetar på servern (till exempel 11-12 nov och 16 nov). |
| Falsklarmsrisk | Medelhög till hög. Varje sudo till root är ett larm, och i normaltrafik kom 8 larm på 32 minuter, alla från student med läsande kommandon (till exempel `nft list ruleset`, `tail -n 50 /var/log/secure`). Larmet säger därför inte att något är fel, utan att playbooken måste skilja kända administrationskommandon från oväntade (till exempel `useradd`, `chmod`, `rm` på loggar, `nmap`). |  