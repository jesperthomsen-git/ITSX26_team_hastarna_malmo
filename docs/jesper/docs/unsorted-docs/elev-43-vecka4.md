# Ö1. Två lager. Molnplattformens brandvägg och nftables på värden – nämn en sak var och en kan som den andra inte kan i vår miljö.

Molnplattformen kontrollerar in och ut från internet och nftables kontrollerar värden inom privata nätverk

# Ö2. Var hör raden hemma? Avgör för varje flöde om det filtreras i molnbrandväggen, på värden eller båda: 
a) internet → webbservern tcp/443, - Molnbrandvägg och nftables då den går via internet till en server och nftables är där som extra skydd
b) appservern 10.40.7.20 → databasen 10.40.7.30 tcp/5432 - nftables/värden privat nätverk där man kan använda tabellen för att avgränsa vad som släpps igenom
c) jump 172.20.1.2 → din server tcp/22 -nftables/värden detta är för att ssh inte är kopplad till internet och går direkt till privat nätverk
d) din server → Hetzners DNS 185.12.64.1 udp/53. -nftables/värden behöver inga regler för att för att komma åt DNS servers

# Ö3. Utgående riktning. Din molnbrandvägg har bara inkommande regler. Vad händer med utgående trafik? Vad händer när du lägger till en enda utgående regel för tcp/443? 

svar: Om jag bara har ingående regler så är all trafik utåt tillåtet. om jag lägger till tcp 443 blir allt annat än den regeln nekad. 

# Ö4. Ordningen. Varför ska ct state established,related accept ligga först i båda kedjorna? Vad händer med din SSH-session om du sätter policy drop på input innan den regeln finns? 

svar: Regler går uppifrån och ner, ct state established,related accept tillåter redan godkända paket igenom och behöver inte prövas igen. om ssh reglerna är över drop blir dem först godkända och sedan blir dem överstrykna av den nya regeln och stoppar alla paket som skickas till ens server. 


# Ö5. Policy eller regel? Vad är skillnaden mellan att sätta policy drop på en kedja och att lägga en sista regel drop? Vilken skillnad gör det för var loggregeln ska ligga?

svar: policy drop är default deny, den är inte en regel men en standard för resterande regler. en regel kan avgränsa trafik som t.ex mot en specifik IP address eller port. 



# Ö6. Reserverade adresser. Teamets nät i Hetzner är 10.40.7.0/24 med subnätet 10.40.7.0/26. Vilka adresser kan du inte ge din server, och varför?
svar: Enligt Hetzner tar dem alltid första IP addressen i nätet så från 10.40.7.1/24

/26 = 64 addresser
10.40.7.0/26 blir då nätadressen
10.40.7.1/26 Hetzner
10.40.7.63/26 är broadcast
10.40.7.2/26 är första användbara
10.40.7.62/26 är sista användbara


# Ö7. Tre utfall. Beskriv paketmönstret i en fångst för 
a) tyst drop - sändaren kan inte se om servern finns eller är nere och fortsätter tills den går på timeout
b) avvisning från filtret - strikt nej och får kommentar att det nekas av filter
c) framme men avvisat av tjänsten. Vilken returkod ger förövningens skript i varje fall? - kommer hela vägen men får sedan ett nej från tjänsten


# Ö8. Läs en loggrad. ZON-IN-DROP IN=eth1 OUT= SRC=172.20.1.203 DST=172.20.1.107 LEN=60 TTL=64 PROTO=TCP SPT=51922 DPT=46472 SYN – vilken riktning, vilken källa, vilken port, vilket skede av anslutningen? Vilken regel skrev raden?

Svar: kedjan in släpps mot eth1, källan var 72.20.1.203 och försökte komma till 172.20.1.107 genom TCP från port 51922 till port 46472 och försöker påbörja en TCP-anslutning med paketlängden 60, time to live 64 som är antalet hopp innan den "dör".

riktning in
vilken källa 72.20.1.203:51922
vilket skede av anslutningen? försöker påbörja en TCP-anslutning
Vilken regel skrev raden - ip saddr 172.20.1.203 tcp dport 46472 log prefix "ZON-IN-DROP" drop
ZON-IN-DROP menas med att det antingen inte finns en regel och har default deny på eller så använder den regeln ovan



# Ö9. Beständigt. Du har laddat regelverket med nft -f och allt fungerar. Servern startas om. Vad krävs för att regelverket ska finnas kvar?

svar: namn.nft måste laddas in genom nftables.conf och config filen måste ha include /directory/namn.nft för att möjliggöra att reglerna laddas om var gång servern startar om. kommandot sudo systemctl enable --now nftables måste läsas in för att se till att config filen laddas vid omstart.

# Ö10. Ett nekat test som inte bevisar något. Ditt testfall mot port 9000 gav avvisad. Nämn två anledningar till att det inte bevisar att din regel fungerar, och hur du tar reda på vilken som gäller.

svar: avvisad är antingen att du har lagt en för sträng regel eller så användaren på andra siden skapat en regel som blockerar dig från att koppla åt dig. Då du inte får en kommentar tillbaka att du har blivit avvisad från filtret så måste det vara en reject från något håll.
Andra alternativet är att porten du försöker koppla till inte har en tjänst som lyssnar på den porten. 

sudo ss -lntp | grep :9000 för att kolla om någon lyssnar
eller
sudo nft list ruleset för att se om reglerna är för stränga