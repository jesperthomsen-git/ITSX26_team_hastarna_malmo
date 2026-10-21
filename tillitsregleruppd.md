## Tillitsregler för nätverket

Reglerna nedan kopplar Zero Trust-principerna till adressplanen. **En IP-adress eller nätzon ger inte i sig tillit.** Verifiera användare och tjänster, kontrollera enhetens säkerhetsstatus och ge endast den åtkomst som behövs.

### Grundregler

1. **Neka som standard** trafik mellan zoner och ut från nätverket. Tillåt bara dokumenterade flöden.
2. **Kräv identitet och behörighet.** Använd nätverkszon som en del av kontrollen, inte som enda åtkomstvillkor.
3. **Begränsa varje regel** till en källa, ett mål, en tjänst och ett angivet syfte.
4. **Logga åtkomst och regeländringar.** Ange regelägare, godkännare och granskningsdatum.
5. **Tidsbegränsa undantag.** Ange slutdatum och ansvarig ägare.

### Zonregler

| Zon | Adressblock | Tillitsregel |
|---|---|---|
| DMZ | `10.40.0.0/23` | Tillåt endast publicerade tjänster från internet. Tillåt vidare trafik till applikationszonen endast när den behövs för en namngiven tjänst. |
| Applikation | `10.40.2.0/23` | Tillåt trafik från godkända klienter, DMZ-tjänster och driftverktyg endast för dokumenterade behov. |
| Data | `10.40.4.0/23` | Tillåt endast nödvändiga anslutningar från godkända applikationstjänster och driftroller. Neka direkt trafik från internet, klienter och utvecklingsmiljöer. |
| Driftstjänster | `10.40.6.0/23` | Tillåt övervakning, loggning, backup och patchning endast från godkända driftkomponenter och till definierade mål. |
| Klienter | `10.40.16.0/21` | Tillåt åtkomst till godkända användartjänster. Neka direkt åtkomst till databaser och managementgränssnitt. |
| Utveckling och test | `10.40.24.0/22` | Håll åtskild från produktion. Tillåt inga produktionsanslutningar utom särskilt godkända och begränsade flöden. |
| Labb | `10.40.28.0/24` | Isolera från produktionsmiljöer. Tillåt bara dokumenterad åtkomst till testresurser. |
| Management och out-of-band | `10.40.29.0/24` | Tillåt administrativ åtkomst från godkända administratörsenheter, med stark autentisering och loggning. Använd jump server där det är möjligt. |
| Integration | `10.40.128.0/17` | Dela upp per partner eller integration. Tillåt endast avtalade flöden via godkända gateways. Behandla inte hela blocket som en gemensam betrodd zon. |
| Reserverat | `10.40.8.0/21`, `10.40.30.0/23`, `10.40.32.0/19` | Tilldela inga system eller tillåtna trafikflöden förrän blocken har fått en ägare, ett syfte och godkända regler. |
| Oallokerat | `10.40.64.0/18` | Håll utan aktiva tilldelningar och åtkomstregler tills adressutrymmet har planerats. |

### Tillåtna flöden – utgångspunkt

| Källa | Mål | Regel |
|---|---|---|
| Internet | DMZ | Tillåt endast publicerade tjänster. |
| Internet | Applikation, data, drift, klienter och management | Neka direkt trafik. |
| DMZ | Applikation | Tillåt endast dokumenterad tjänstetrafik till angivna mål. |
| Applikation | Data | Tillåt endast nödvändiga dataanslutningar från godkända applikationer. |
| Klienter | Applikation | Tillåt godkända användarflöden. |
| Klienter | Data och management | Neka direkt trafik. |
| Management | Servrar och nätverksenheter | Tillåt administrativ åtkomst med verifierad identitet, godkänd enhet och loggad session. |
| Utveckling/test och labb | Produktion | Neka som standard. Undantag kräver ägare, syfte och slutdatum. |
| Driftstjänster | Hanterade system | Tillåt endast de flöden som krävs för övervakning, backup, loggning och patchning. |

Lägg till nödvändiga tjänster och portar först när de har identifierats och godkänts. Begränsa även utgående trafik till godkända mål, till exempel organisationens DNS-, tids- och uppdateringstjänster.

### Koppling till Zero Trust-pelarna

| Pelare | Regel för denna adressplan |
|---|---|
| **Nätverkssegmentering** | Dela produktionsblocket `10.40.0.0/20` i separata DMZ-, applikations-, data- och driftzoner. Dela integrationsblocket vidare per partner eller tjänst. |
| **Trafikstyrning** | Börja med dokumenterade brandväggsregler. Ange källa, mål, tjänst, ägare och syfte. Automatisera ändringar först när godkännanden och loggning fungerar. |
| **Kryptering** | Skydda trafik mellan zoner och administrativa anslutningar med godkända, aktuella krypteringsmetoder. |
| **Nätverksresiliens** | Dokumentera återställning av kritiska brandväggar, gateways, DNS och andra nätverkstjänster. Testa återställningen. |
| **Synlighet och analys** | Samla loggar från brandväggar, gateways, autentisering och centrala tjänster. Larma på oväntad trafik mellan zoner. |
| **Automatisering och orkestrering** | Automatisera regelkontroller och återkommande uppgifter stegvis. Kräv godkännande för ändringar som påverkar känsliga zoner. |
| **Styrning** | Ge varje regel en ägare, ett syfte, ett godkännande och ett granskningsdatum. Ta bort regler när behovet upphör. |

**Regelmall:**

> Tillåt endast när identiteten och enheten är godkända, källan och målet är specificerade, tjänsten behövs för ett dokumenterat syfte och åtkomsten loggas. Annars: neka.

Behandla adresser och zoner som delar av policyn, inte som identitetsbevis. Bekräfta exakta trafikbehov med tjänsteägarna innan regler införs.