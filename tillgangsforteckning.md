# Tillgångsförteckning  

Det här är ett planeringsregister baserat på adressplanen. Det innehåller zoner och tillgångsgrupper, inte en verifierad lista över installerade servrar. Lägg till en rad för varje faktisk server, virtuell maskin, nätverksenhet och klient. Fyll i faktiska namn och IP-adresser när de är kända.  

| ID | Tillgång eller grupp | Nät | Exempel på innehåll | Föreslagen ansvarig | Kritikalitet / exponering |
|---|---|---|---|---|---|
| ZONE-DMZ | DMZ-zon | 10.40.0.0/23 | Publika webbservrar, omvänd proxy, WAF | Drift & System; bekräfta tjänsteägare | Hög; nås från internet endast via godkända tjänster |
| ZONE-APP | Applikationszon | 10.40.2.0/23 | Applikationsservrar, interna API:er | Drift & System; bekräfta applikationsägare | Hög; nås endast från godkända zoner |
| ZONE-DATA | Datalagringszon | 10.40.4.0/23 | Databaser, filservrar, lagring | Drift & System; bekräfta dataägare | Hög; ingen direkt åtkomst från internet eller klienter |
| ZONE-OPS | Driftstjänster | 10.40.6.0/23 | Övervakning, loggning, backup, patchning | Drift & System | Hög; åtkomst begränsas till driftbehov |
| ZONE-CLIENT | Klientzon | 10.40.16.0/21 | Personalens datorer och arbetsstationer | IT-support | Medel; klienter bör inte nå databaser direkt |
| ZONE-DEVTEST | Utveckling och test | 10.40.24.0/22 | Utvecklingsservrar, testmiljöer | Utvecklingsteam | Medel; håll åtskild från produktion |
| ZONE-LAB | Labbzon | 10.40.28.0/24 | Labbservrar och testriggar | Lab-ansvarig | Varierar; begränsa kopplingar till produktion |
| ZONE-MGMT | Management och out-of-band | 10.40.29.0/24 | Administratörsarbetsstationer, jump server, hanteringsgränssnitt | Nätverkstekniker | Hög; åtkomst endast för behöriga administratörer |
| ZONE-INT | Integration | 10.40.128.0/17 | Integrationsgateways och partneranslutningar | Integration / Gateway | Hög; dela upp per partner eller integration |
| RES-PROD | Reserv inom produktionsblocket | 10.40.8.0/21 | Ej tilldelad | Drift & System eller Arkitektur; bekräfta | Reserverad; inga aktiva värdar |
| RES-30 | Framtida expansion | 10.40.30.0/23 | Ej tilldelad | Ej tilldelad | Reserverad; inga aktiva värdar |
| RES-32 | Reserverat tjänsteutrymme | 10.40.32.0/19 | Ej tilldelad | Arkitektur | Reserverad; inga aktiva värdar |
| RES-64 | Öppet adressutrymme | 10.40.64.0/18 | Ej tilldelad | Ej tilldelad | Oallokerad; inga aktiva värdar |  