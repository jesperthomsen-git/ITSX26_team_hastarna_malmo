# Incidentrapport eMudhra  

## Vad hände  

En certifikatutfärdare som heter eMudhra hade gjort fel när den skapade åtta certifikat. De hemliga nycklarna till dem gick att räkna ut av vem som helst. Då kan en angripare låtsas vara vilken webbplats som helst. Certifikaten litas på av Mozilla, Microsoft, Apple och Chrome, så felet var allvarligt.  

## Tidslinje  

- April 2025: certifikaten skapas, och felet kan ha funnits redan då.
- 17 oktober 2026: någon rapporterar felet och bevisar det. Firefox och Chrome blockerar certifikaten.
- 19 oktober: Apple blockerar dem.
- 20 oktober: Microsoft blockerar dem, certifikaten återkallas och incidenten publiceras.  

## Vad var orsaken  

Nycklarna skapades på fel sätt. Därför kunde vem som helst räkna ut dem utifrån certifikaten.  

## Vem drabbbades  

Webbläsarna var skyddade. De kräver att certifikat syns i offentliga loggar (Certificate Transparency), och här fanns inga sådana certifikat, så en attack hade inte gått igenom. Andra program, till exempel kommandoradsverktyg, kräver ofta inte det och läser inte heller återkallningslistor. Om någon har utnyttjat felet mot dem vet man inte.  

## Vad har gjorts  

Webbläsare och operativsystem har blockerat certifikaten, och eMudhra har återkallat dem. Flera Linux-system och bibliotek har släppt uppdateringar. Användare ska uppdatera sina webbläsare och sina system.  

