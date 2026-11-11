# Rule nr1
Rör aldrig orginalet
Arbeta alltid mot kopian
Hasha både orginal och kopia - summorna måste matcha

```sha256sum exempel.txt```
sedan
```sha256sum -c exempel.sha256```

## varför loggar vi?

* Bevisa vad vi har gjort
* Kunna återskapa det
* Hålla för granskning- kunna visa hur/vad du har gjort

## Två principer 
* Chain of custody -Vem har tillgång och när
* Reproducerbarhet - Någon annan ska kunna följa dina fotspår

## En rad per åtgärd, fem fält

| Tid UTC | Vem | Vad gjordes | Verktyg/kommando | Resultat |
| ------- | --- | ----------- | ---------------- | -------- |
|         |     |             |                  |          |
|         |     |             |                  |          |
|         |     |             |                  |          |
|         |     |             |                  |          |
printf '%s | %s | %s | %s | %s\n' "Tid UTC" "Vem" "Vad gjordes" "Verktyg" "Resultat"
printf '%s | %s | %s | %s | %s\n' "$(date -u '+%FT%TZ')" "$(uname -nr)" "ble" "bli" "blu"

## Contemporaneous notes

* Skriv medans du arbetar - reflektera inte om vad du gjorde innan
* Sudda aldrig misstag eller fel, allt loggas

Istället: Stryk över och kommentera istället

"Logg med ärligt redovisade fel/misstag är mer trovärdigt än en som ser perfekt ut"

## Så loggar du

* Ta skärmbilder vid varje viktigt steg länka denna till kommando/kolumnerna ovan för enklare loggning 
* Skriv löpande och kommentera ofta
* Alltid logga i UTC format
* Numrera och namge bevisen på ett sätt så det kan återkopplas till loggen och var/när det skedde

## Script och tee

Loggen nedan startar script för att skapa en logg

 ```script -q -c "date -u +%FT%TZ; uname -nr" caselog.log```
#### osäkerhet:
Vet ej om denna skapar alla kolumnerna som t.ex 


Använd pipe med tee för att kunna skapa en log av aktivitet medans du skriver kommandon för att få detta skrivet till en fil. evidense.txt är exempel

```| tee -a evidense.txt```
## Hashning

Använd sha256sum för att skapa en hashning som ses som ett fingerprint

Exempel: 
	 ``` sha256sum evidense.txt```

För att kunna verifiera att filen inte har rörts vid efter hashningen:
	```evidense.sha256```
sedan:
	```sha256sum -c evidense.sha256```

OK == oförändrad hash, integriteten är kvar
FAILED == Kan inte lita på fil då integriteten inte är kvar

 #### Osäkerhet:
  om man kan använda tee -a för att kunna skapa
  eller skriva över hashes till caselog.log

## Granska innehållet

Frågor
---
*Är tidslinjen sammanhängande? luckor?*
*Följer varje åtgärd logisk föregående kommando?*
*Går stegen att åteskapa?

Flaggor: Arbete direkt på orginalet istället på kopia loggen och oförklarade hopp i tiden

## Planering innan du skapar logg

* Ofta endast en chans
* Fel hantering kan förstöra bevis
* Veta vad du letar efter innan du börjar

Fem steg
---
1. definera frågeställningen, vad ska du ta reda på?
2. identifiera och säkra källor, vilka enheter eller system?
3. Bestäm ordning eller flyktighet
4. Förbered verktyp eller kommandon innan du börjar
5. Bestäm hur bevisen ska hanteras eller förvaras

## Order of volatility

Fånga data, prioritet:
1. RAM 
2. Aktiva nätverksanslutningar, portar eller processer
3. Temp filer
4. Hårddisk & Lagring
5. Säkerhetskopior och arkiv

