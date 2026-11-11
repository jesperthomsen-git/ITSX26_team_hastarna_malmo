# Fyra nedbrytningar (Wazuh)  

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
| Brus i hela verifierade fönstret | Under 50 timmar (9 nov 09:00 till 11 nov 11:00) fick jag 4 träffar, ungefär 0,08 per timme. Alla fyra var mina egna tester: jag försökte nå 1.1.1.1 på port 8080, två gånger den 9 nov och två gånger i dag kl 10:36. Brandväggen stoppade ingen annan trafik. |
| Falsklarmsrisk | Låg. I normaltrafik stoppade brandväggen ingenting (0 träffar på 32 minuter), så varje träff är värd att titta på. Falsklarm kan ändå uppstå om en tjänst försöker nå något som flödestabellen saknar, till exempel en ny uppdateringsserver, eller om vi själva testar med `/dev/tcp`. | 

