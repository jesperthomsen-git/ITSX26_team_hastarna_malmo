# Egna uppgifter – kamraträttning

> **Granskning av kamrat:** Orginal svar är orörda. Efter varje svar finns en rad med **Rättning** (✓ = rätt, ? = frågetecken) och **Kommentar**. Jag har fyllt ✓/? utifrån min genomgång.

nätadress, broadcastadress, första och sista användbara adress och antal användbara
värdar

| IP | Nätadress | broadcastadress | första och sista | antal användbara värdar | Rättat svar | ✓/? | Din kommentar |
|---|---:|---:|---:|---:|---:|:---:|---|
| 10.40.5.130/25 | 10.40.5.128/25 | 10.40.5.255/25 | 10.40.5.129-254 | 126 | 128–255 | ✓ | Helt rätt! |
| 10.40.77.200/26 | 10.40.77.192/26 | 10.40.77.255/26 | 10.40.77.193-254 | 62 | 0 | ? | Nät och broadcast inte rätt /rättat e43|
| 10.40.101.37/28 | 10.40.101.32/28 | 10.40.101.47/28 | 10.40.101.33-46/28 | 14 | 32-47 | ? | broadcast och sista användbara /rättat e43|
| 10.40.9.250/29 | 10.40.9.248/29 | 10.40.9.255/29 | 10.40.9.249-254 | 6 | 248-255 | ✓ | helt rätt! |
| 10.40.70.66/30 | 10.40.70.64/30 | 10.40.70.67/30 | 10.40.70.65-66 | 2 | 0 | ? | Nät, brodcast samt interval blev inte rätt /rättat e43|
| 10.40.150.10/22 | 10.40.148.0/22 | 10.40.151.255/22 | 10.40.148.1 - 10.40.151.254 | 1022 | 148-151.254 | ? | Broadcast och sista blev inte rätt  /rättat e43|
| 10.40.45.1/20 | 10.40.32.0/20 | 10.40.47.255/20 | 10.40.32.1 - 10.40.47.254 | 4094 | 0 | ✓ | Helt rätt! |


**Kommentar:**  

---

## R8

Dela 10.40.64.0/23 till 200, 90 och 30 värdar och en länk mellan två routrar. Ange prefix och nätadress för varje nät

10.40.64.0/23
/24
/25
/27

| Rättning | Kommentar |
|:---:|---|
| ? | Prefixen är rätt men adresserna saknas och länk nätet mellan router - router har ingen eget prefix |

---

## Förberedelsefrågan

172.20.1.0/24
254 servrar
skulle skapa två subnät av /25, då delas 128 servrar på en del och resten på den andra

| Rättning | Kommentar |
|:---:|---|
| ? | Ett /25 har bara 126 användbara adresser därför ryms inte 128 servrar i ett av näten. Två ger totalt /25 ger 252 användbara adresser. Det behövs en adress för gateway också. |

---

## Instuderingsövningar

### 1 Mask och prefix

/27 = 32
256-32 = 224
255.255.255.224

/22 = 4.0
256-4=252
255.255.252.0

/19 32.0
256-32=224
255.255.224.0


/29=8
256-8=248
255.255.255.248


255.255.255.224= /27
255.255.252.0= /22
255.255.255.248= /29


255=8bits
240=4bits
8+4=12
255.240.0.0= /12

| Rättning | Kommentar |
|:---:|---|
| ✓ | Allt är rätt här! |

### 2 Hur många värdar

/23 = 2.0
8bits=256
256*2=512
netid-bcip-512=510


/21=8.0
8bits=256
256*8=2048
2048-2=2046

/28 = 16
8bits=256
256/16 = 16
16-2=14

/24 rymmer 150
/26 rymmer 40
/23 rymmer 500

| Rättning | Kommentar |
|:---:|---|
| ✓ |"netid-bcip är otydlig" intressant sätt att räkna. Svaren är rätt men  254> 150 /25 126 räcker inte. |

### 3 Hur många nät

4 /26 passar i ett /24
det kräver 64 /24 för att få plats i en /18

| Rättning | Kommentar |
|:---:|---|
| ✓ | Denna är också rätt! |

### 4 Samma subnät?

1. 10.40.65.60/26 och 10.40.65.70/26 
ja dessa är i samma subnät då /26 kan ha 62 användbara hosts

| Rättning | Kommentar |
|:---:|---|
| ? | 10.40.65.60 ligger i 65.0–63 och .70 i 65.64–127. De ligger i olika subnät. |

2. 172.16.31.255/20 och 172.16.32.1/20
ja dessa är i samma när då det är innanför samma subnät range av 16 delar

| Rättning | Kommentar |
|:---:|---|
| ? | 172.16.31.255 ligger i 172.16.16.0/20 (16–31) och 172.16.32.1 i 172.16.32.0/20. Olika subnät. |

3. 192.168.1.126/25 och 192.168.1.129/25
Inom samma antal av värdar som är 126

| Rättning | Kommentar |
|:---:|---|
| ? | .126 ligger i 192.168.1.0/25 och .129 i 192.168.1.128/25. Olika subnät. |

4. 10.40.255.0/31 och 10.40.255.1/31
denna är också inom samma ram då du kan endast ha 2 värdar i denna prefix

| Rättning | Kommentar |
|:---:|---|
| ✓ | Samma subnät. Svaret är rätt, men borde vara att båda adresserna ligger i 10.40.255.0/31. Inom antalet avvändbar värdar är fel metod. Man måste jämföra nätadresserna. |

### 5 Överlapp

Då /18 använder 64 delar av ett /24 kommer 10.40.64.0/18 och 10.40.100.0/24, detta kan skapa ip utdelningsfel, utlåsning och att servrar och tjänster slutar att fungera som dem ska

| Rättning | Kommentar |
|:---:|---|
| ✓ | Att nätena överlappar är rätt! |

### 6 Länknät

Enligt RFC 3021 måste routrarna vara inom samma 32-bit mask. Subnätsnummer bör inte användas, bara om det är inom samma 31 bit, enligt RFC kan kommunikation med olika subnät vara samma nät tex /18-1 för att skapa en länk

Enklaste är att koppla båda mot /31 för att spara IP addresser gentemot /30 som har 4

| Rättning | Kommentar |
|:---:|---|
| ? | Slutsatsen (/31 sparar adresser jämfört med /30) är rätt, men resonemanget om “32-bit mask” och “/18-1” är förvirrande och stämmer inte. RFC 3021 säger att på punkt-till-punkt-länkar kan ett /31 användas, där båda adresserna är värdadresser och nät- och broadcastadress saknas. Ett /30 förbrukar fyra adresser för två routrar. |

### 7 Summering

/21 får plats för alla IP addresserna då det är inom samma antal delar för oktatet som ä 4
Det går att ha alla 10.40.66.0/24–10.40.69.0/24 under ett /21 subnät där 10.40.64.0/21 och 10.40.71.255/21 kommer vara innanför ramen för subnätet

| Rättning | Kommentar |
|:---:|---|
| ✓ |/21 är rätt (10.40.64.0–10.40.71.255). Förklaringen saknas dock: ett /22 räcker inte eftersom 66–69 sträcker sig över blockgränsen vid 68 (64–67 och 68–71). Ett /21 är den minsta enskilda summeringen. |

### 8 VLSM

/23 för 510 användvara hosts
/24 för 254
/25 för 126
/26 för 62
/31 för två routrar

| Rättning | Kommentar |
|:---:|---|
| ✓ | Värdena är rätt som maxantal per prefix, och /31 för två routrar korrekt! |

### 9 Privat eller inte

Vilka av adresserna är privata enligt RFC 1918: För de som inte är det – vad är de i stället?

172.32.5.1, Detta är inte privat då ramen är: 172.16.0.0 - 172.31.255.255
offentligt IP som kan användas av företag som exempel utan behov för koordination med IANA eller internet registry(IR)

| Rättning | Kommentar |
|:---:|---|
| ? | 172.32.5.1 är offentlig, och 172.31.200.9, 10.255.0.1 och 192.169.0.1 är rätt bedömda. 172.32.5.1 är bakvänd: det är de privata adresserna som kan användas utan samordning med IANA/RIR. Offentliga adresser tilldelas via dem. |

172.31.200.9,Privat

| Rättning | Kommentar |
|:---:|---|
| ✓ |  Helt korrekt! |

10.255.0.1, privat

| Rättning | Kommentar |
|:---:|---|
| ✓ | Helt korrekt! |

192.169.0.1, Offentligt då ramen för privat är 192.168.0.0 - 192.168.255.255

| Rättning | Kommentar |
|:---:|---|
| ✓ | Även denna korrekt! |

100.64.3.4, offentligt (rättat shared address space)

| Rättning | Kommentar |
|:---:|---|
| ✓ | 100.64.3.4 (delat adressutrymme/CGNAT, RFC 6598) och 192.0.2.10 (dokumentation/TEST-NET-1, RFC 5737) är inte RFC 1918, men inte heller vanliga offentliga adresser. Skriv hellre “specialadress” än “offentligt”. |

192.0.2.10? offentligt (rättat documentation)

| Rättning | Kommentar |
|:---:|---|
| ✓ | Korrekt! |

### 10 Tillgångar och zoner

| tillgång | klass(låg, medel, hög) | Zon | ✓/? | Din kommentar |
|---:|---:|---:|:---:|---|
| Publik webbserver | Medel | 10.40.44.0/23 | ✓ | Rätt! |
| applikationsserver | medel | 10.40.46.1/24 | ? |  |
| kunddatabas med personuppgifter loggserver | hög | 10.40.47.1/29 | ? | Inget fel. Kunddatabas och loggserver är i hopklistrade, det blir två tillgångar |
| jump-server för administration | hög | 10.40.47.17/28 | ? | Inte fel, men lite otydligt|
| loggserver | hög | 10.40.47.19/28 | ? | Samma med jump-server kan var uppsåtligt men står inte med  |
| 30 arbetsplatser | låg | 10.40.47.65/27 | ? | ett /27 har exakt 30 användbara adresser, så det finns ingen plats för gateway. Ett /26 behövs. |

Missade:
DMZ: webbservern
applikation: applikationsservern
data:kunddatabasen
drift och förvaltning: jump servern
klienter: arbetsplatserna

Misstog detta mot IP addresser

Man ska inte sätta databaser eller segment som har känslig information tillsammans med publika nätverk som kan skapa en attackyta av olika slag. genom segmentering behöver attackeraren gå igenom flera segment för att ta sig till vart den vill vilket kan öka möjligheten för att fånga viktig information om attacken.

| Rättning | Kommentar |
|:---:|---|
| ✓ | Klassningen är bra och självrättningen (DMZ, applikation, data, drift, klienter) är bra. Zonnamnen borde stå i tabellen. I helhet är där detta toppen men det saknas brandväggsregler.|

---


**Övergripande kommentar till kamraten:** Hej Jesper bra jobbat! Jag tog lite hjälp av AI för att göra en kopia av din orginal fil för att göra kommentarsfält, samt spalt för | ✓ | ?  | allt annat är orört. 
Uppgifterna har jag granskat med ipcalc, på egen maskin. Likväl verifierat mot AI, på frågor som inte hade "INVALID NETMASK". Det syns att du förstår grundidén med subnetting hur masker och prefix hänger ihop, hur många värdar ett nät rymmer och hur man delar upp adressutrymme med VLSM. Ditt resonemang om att segmentera känsliga system från publika i Ö10 var också välgjort, och jag gillar att du rättade dig själv där och i Ö9. Vilket jag helt missade i mitt egna arbete.