# Flödestabell

Utkast. Portarna är standardportar och ska slås upp i IANA-registret innan de används.

| Rad | Källzon | Målzon | Protokoll | Port | Riktning | Motivering (verksamhetsfunktion) | Filtreras var |
|---|---|---|---|---|---|---|---|
| 1 | Internet | DMZ | tcp | 443 | Utifrån in | Kunder når den publika portalen | Moln, eftersom trafiken kommer utifrån |
| 2 | Klienter | DMZ | tcp | 443 | Klienten startar | Personalen använder portalen | Värd, eftersom båda ligger på det privata nätet |
| 3 | DMZ | Applikation | tcp | 8080 | Webbservern startar | Portalen hämtar orderdata åt användarna | Värd, privata nätet |
| 4 | Applikation | Data | tcp | 5432 | Appservern startar | Appen läser och skriver kunddata | Värd, privata nätet |
| 5 | Internet (administratör) | Management (jump) | tcp | 22 | Utifrån in | Administratörer loggar in på jump-servern med nyckel | Moln, eftersom trafiken kommer utifrån |
| 6 | Management (jump) | Alla servrar | tcp | 22 | Jump startar | Förvaltning och underhåll av servrarna | Värd, privata nätet |
| 7 | Alla servrar | Driftzonen (loggserver) | tcp | 6514 | Servern startar | Central loggning över TLS, så att vi kan visa vem som gjort vad | Värd, privata nätet |
| 8 | Alla servrar | Extern DNS-server | udp | 53 | Servern startar | Namnuppslag, så att tjänster hittar varandra | Moln, utgående mot internet |
| 9 | Alla servrar | Extern tidskälla | udp | 123 | Servern startar | Rätt tid, så att loggar och certifikat stämmer | Moln, utgående mot internet |
| 10 | Alla servrar | Uppdateringsserver | tcp | 443 | Servern startar | Säkerhetsuppdateringar och patchning | Moln, utgående mot internet |
| 11 | Driftzonen | Hanterade system | tcp | TBD | Driften startar | Övervakning, backup och patchning. Port identifieras innan implementation | Värd, privata nätet |
| 12 | Allt annat | Allt annat | alla | alla | Båda riktningarna | Allt som inte står ovan är nekat, inkommande och utgående | Moln och värd |