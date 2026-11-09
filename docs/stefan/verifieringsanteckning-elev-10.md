# Verifieringsanteckning – elev-10

| Identifierare | Tid (UTC) | Värdnamn | Källa | Söksträng | Hittad centralt? | Avvikelse |
|---|---|---|---|---|---|---|
| Testhändelse U5.5, `spar4f3a4474` | 2026-11-05 09:20:22 | elev-10 | System (user.notice) | `loggsök spar4f3a4474` | Ja, TLS | Inga. Tidsstämpel med delsekunder och tidszon. |
| Inloggning: Accepted publickey for student | 2026-11-05 08:34:22 | elev-10 | Autentisering (sshd) | `loggsök sshd` | Ja, TLS | Tidsstämpel utan delsekunder (före RFC 5424-mallen). |
| `sudo cat /etc/rsyslog.d/60-brandvagg.conf` | 2026-11-05 09:03:08 | elev-10 | Root-kommando (sudo, audit) | `loggsök sudo` | Ja, TLS | Utan delsekunder (före mallen). `auid=1000` visar att det var student. |
| Testanslutning till 1.1.1.1 port 8080, nekad | 2026-11-06 12:30:33 | elev-10 | Brandvägg (kernel, ZON-UT-DROP) | `loggsök ZON-UT-DROP` | Ja, TLS, två SYN | Inga. Tidsstämpel med delsekunder och tidszon. |