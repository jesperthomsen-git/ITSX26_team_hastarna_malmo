# Adressplan

Teamets tilldelade IPv4-block är:

10.40.44.0/22

Adressplanen är framtagen med VLSM. Varje nät har fått det
minsta möjliga prefix som rymmer det angivna antalet värdar.

| Nät | Behov | Subnät | Användbara adresser | Broadcast | Syfte |
|---|---:|---|---|---|---|
| Klienter | 313 | 10.40.44.0/23 | 10.40.44.1–10.40.45.254 | 10.40.45.255 | Klientdatorer |
| Servrar | 128 | 10.40.46.0/24 | 10.40.46.1–10.40.46.254 | 10.40.46.255 | Servrar och servertjänster |
| Drift och övervakning | 23 | 10.40.47.0/27 | 10.40.47.1–10.40.47.30 | 10.40.47.31 | Administration och övervakning |
| Länknät | 2 | 10.40.47.32/30 | 10.40.47.33–10.40.47.34 | 10.40.47.35 | Punkt-till-punkt-länk |

## Uträkningar

### Klienter

Behov: 313 värdar.

Ett /24 ger 254 användbara adresser och är därför för litet.
Ett /23 ger 510 användbara adresser.

Val: 10.40.44.0/23.

### Servrar

Behov: 128 värdar.

Ett /25 ger 126 användbara adresser och är därför för litet.
Ett /24 ger 254 användbara adresser.

Val: 10.40.46.0/24.

### Drift och övervakning

Behov: 23 värdar.

Ett /28 ger 14 användbara adresser och är därför för litet.
Ett /27 ger 30 användbara adresser.

Val: 10.40.47.0/27.

### Länknät

Behov: 2 användbara adresser.

Ett /30 innehåller fyra adresser, varav två är användbara
värdadresser.

Val: 10.40.47.32/30.

## IPv6

IPv6 ska ses som en förutsättning för den framtida lösningen.
Adress- och zonindelningen ska därför kunna kompletteras med
IPv6/dual-stack utan att den logiska segmenteringen behöver
göras om.