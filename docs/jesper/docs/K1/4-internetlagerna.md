
## 01 Applikationslager  
---  
SSH, HTTP användar protokoll  
  
Stödprotokoll: DNS uppslag, NTP, DHCP 
### Säkerhetsrisk:  
Innehållet sysns i app. lager, om paket skickas okrypterat syns hela paketet  
  
## 02 Transportlager  
---  
TCP - handshakes, seqnr. redirects - Passar bra för SSH, HTTP syslog & mails  
  
UDP - Ett meddelande, shotgun av paket hoppas att alla kommer fram, DNS, NTP, DHCP, Gaming, Streaming  
  
QUDP - uppdaterat modernt protokoll för t.ex sociala medier som är krypterat  
  
### Säkerhetsrisk:  
 Visar portar som lyssnar, kan skapa säkerhetsrisk då den visar attackyta genom aktivare portar som inte skall vara öppna vanligtvis  
  
## 03 Internetlager  
---  
IP är förbindelselös datagram tjänst och fungerar nästan som UDP, skickar data så gott den kan  
TCP skapar struktur och skickar ett paket i taget efter att internet lagret har skickat datan  
  
ICMP kontroll protokoll som är integrerat i internetlagret men fungerar som ett protokoll så som UDP eller TCP  
ICMP står för felrapportering, rapport av överbelastning  
  
internetlagret skickar och tar emot packet src dst  
  
Förlust och omordning hanteras av protokoll  
  
### Säkerhetsrisk: IP kontrollerar inte om källaddressen är sann då denna kan förfalskas  
  
  
  
## 04 Länklagret  
---  
För att kommunicera behövs en host, denna kontrollerar och implementerar protokoller  
  
Länklagret är ramar som eth0 mot internet i labben  
Länklagret innehåller MAC addresser och ARÅ  
  
### Säkerhetsrisk:  
den som skickar länkar kan kontrollera och lyssna på det du gör och kan lura ARP  
### Säkerhetssynpunkt:  
Frågan om vem som delar nät med dig, den som står på samma nät kan lyssna av och lura ARP