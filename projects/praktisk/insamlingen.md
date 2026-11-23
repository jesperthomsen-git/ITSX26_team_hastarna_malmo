# Insamlingen – Team 4 Hästarna

Teamets servrar skickar system-, autentiserings- och brandväggsloggar till den gemensamma loggservern (`log.sec.chas-lab.dev`, `172.20.1.58`, port 6514) över TLS. Det här dokumentet visar konfigurationen och att insamlingen fortfarande fungerar efter en omstart. Spårbara testhändelser och söksträngar finns i `verifieringsanteckning-elev-10.md`.

## Konfiguration

Filen `/etc/rsyslog.d/60-brandvagg.conf` på varje server skickar loggar vidare med rsyslog:

- **Transport:** TLS (`StreamDriver="gtls"`, `StreamDriverAuthMode="x509/name"`, mottagare `log.sec.chas-lab.dev`).
- **Kö:** `LinkedList` med `queue.filename="fwd_tls"`, `queue.saveOnShutdown="on"` och `action.resumeRetryCount="-1"`, så att loggar ligger kvar om loggservern inte går att nå.
- **Format:** mallen `RSYSLOG_SyslogProtocol23Format` (nära RFC 5424, med delsekunder och tidszon).
- **Vad som skickas:** `*.info` utom `mail` och `cron`.

## Källor som skickas

| Källa | Frågan den besvarar | Söksträng |
|---|---|---|
| System (rsyslog, user.notice) | Vad hände på servern, och när? | `loggsök omstart` |
| Autentisering (sshd, sudo, audit) | Vem loggade in, och vem körde ett root-kommando? | `loggsök Accepted`, `loggsök sudo` |
| Brandvägg (kernel, ZON-UT-DROP) | Vilken utgående trafik blockerades? | `loggsök ZON-UT-DROP` |

## Omstartstest

Varje server skickade en testhändelse före omstart, startades om med `sudo reboot`, och kontrollerades sedan med `uptime -s`, `systemctl is-active rsyslog auditd nftables chronyd` och nya händelser från alla tre källorna, som söktes fram med `loggsök` på jump-servern. Tiderna är UTC.

| Server | Starttid (UTC) | Tjänster aktiva? | System efter omstart? | Autentisering efter omstart? | Brandvägg efter omstart? | Avvikelse |
|---|---|---|---|---|---|---|
| elev-10 | 2026-11-09 07:50:56 | Ja (rsyslog, auditd, nftables, chronyd) | Ja, 07:51:33 | Ja, 07:51:14 | Ja, 07:51:33 | Nekad NTP mot 213.239.239.166 vid start (regeln D4 släpper bara .164). Händelser från uppstarten mottogs efter cirka 2 minuter. |
| elev-43 | 2026-11-09 08:16:53 | Ja (rsyslog, auditd, nftables, chronyd) | Ja, 08:21:09 | Ja, 08:19:38 | Ja, 08:45:33 | Klockan osynkad före omstart (`isSynced="0"`), synkad efter. NTP mot 213.239.239.164 nekades 08:13:53 (före omstart). Händelser från uppstarten mottogs efter cirka 2 minuter. |
| elev-35 | 2026-11-09 08:48:06 | Ja (rsyslog, auditd, nftables, chronyd) | Ja, 08:48:22 via TLS | Ja, 08:57:04 via TLS | Ja, 08:57:06 via TLS | TLS-regeln saknades i sparad brandväggskonfiguration. Åtgärdad och verifierad efter omstart. Systemhändelsen levererades cirka 2 minuter fördröjt. |

## Iakttagelser

- **Fördröjning efter start:** händelser som skapades under uppstarten kom fram först cirka 2 minuter senare, när anslutningen till loggservern var uppe. Det gäller alla tre servrarna, så det är ett mönster. De tappades inte. Det tyder på att kön och omförsöken fungerar, men orsaken är inte bevisad.
- **Regel som saknades efter omstart:** på elev-35 saknades TLS-regeln i den sparade brandväggskonfigurationen och fungerade bara tills servern startades om. Den lades till och verifierades efter omstart. Omstartstestet hittade alltså ett verkligt fel, och alla servrar bör kontrollera att deras regler är sparade (`sudo nft list ruleset` efter omstart).
- **Tidssynk:** på elev-10 släpper regeln D4 bara UDP 123 mot `213.239.239.164` (ntp1.hetzner.de), så chrony har bara en tillåten tidskälla. Klockan var korrekt (avvikelse 0,000125 s), men det finns ingen reserv. På elev-43 nekades NTP mot `.164` före omstart, och klockan var osynkad då. Teamet kan välja att tillåta fler tidsservrar eller ta bort de andra ur `chrony.conf`.
- **Gamla loggar:** loggar från 5–6 november fanns inte längre på loggservern den 9 november. Lagringstiden centralt är okänd och är en öppen fråga till läraren, så spara egna utskrifter som belägg.

