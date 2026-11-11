
# Egna uppgifter

nätadress, broadcastadress, första och sista användbara adress och antal användbara
värdar

| IP | Nätadress | broadcastadress | första och sista | antal användbara värdar | Rättat svar |
|---|---:|---:|---:|---:|---:
| 10.40.5.130/25 | 10.40.5.128/25 | 10.40.5.255/25 | 10.40.5.129-254 | 126 | 128–255 |
| 10.40.77.200/26 | 10.40.77.191/26 | 10.40.77.256/26 | 10.40.77.192-255 | 62 | 0 |
| 10.40.101.37/28 | 10.40.101.32/28 | 10.40.101.48/28 | 10.40.101.33-47/28 | 14 | 32-47 |
| 10.40.9.250/29 | 10.40.9.248/29 | 10.40.9.255/29 | 10.40.9.249-254 | 6 | 248-255 |
| 10.40.70.66/30 | 10.40.70.63/30 | 10.40.70.68/30 | 10.40.70.64-67 | 2 | 0 |
| 10.40.150.10/22 | 10.40.148.0/22 | 10.40.152.255/22 | 10.40.148.1 - 10.40.152.254 | 1022 | 148-151.254 |
| 10.40.45.1/20 | 10.40.32.0/20 | 10.40.47.255/20 | 10.40.32.1 - 10.40.47.254 | 4094 | 0 |

R8. Dela 10.40.64.0/23 till 200, 90 och 30 värdar och en länk mellan två routrar. Ange prefix och nätadress för varje nät

10.40.64.0/23
/24
/25
/27

## Förberedelsefrågan
172.20.1.0/24
254 servrar
skulle skapa två subnät av /25, då delas 128 servrar på en del och resten på den andra


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

### 3 Hur många nät

4 /26 passar i ett /24
det kräver 64 /24 för att få plats i en /18

### 4 Samma subnät?
1. 10.40.65.60/26 och 10.40.65.70/26 
ja dessa är i samma subnät då /26 kan ha 62 användbara hosts

2. 172.16.31.255/20 och 172.16.32.1/20
ja dessa är i samma när då det är innanför samma subnät range av 16 delar

3. 192.168.1.126/25 och 192.168.1.129/25
Inom samma antal av värdar som är 126

4. 10.40.255.0/31 och 10.40.255.1/31
denna är också inom samma ram då du kan endast ha 2 värdar i denna prefix

### 5 Överlapp
Då /18 använder 64 delar av ett /24 kommer 10.40.64.0/18 och 10.40.100.0/24, detta kan skapa ip utdelningsfel, utlåsning och att servrar och tjänster slutar att fungera som dem ska

### 6 Länknät
Enligt RFC 3021 måste routrarna vara inom samma 32-bit mask. Subnätsnummer bör inte användas, bara om det är inom samma 31 bit, enligt RFC kan kommunikation med olika subnät vara samma nät tex /18-1 för att skapa en länk

Enklaste är att koppla båda mot /31 för att spara IP addresser gentemot /30 som har 4

### 7 Summering
/21 får plats för alla IP addresserna då det är inom samma antal delar för oktatet som ä 4
Det går att ha alla 10.40.66.0/24–10.40.69.0/24 under ett /21 subnät där 10.40.64.0/21 och 10.40.71.255/21 kommer vara innanför ramen för subnätet

### 8 VLSM 
/23 för 510 användvara hosts
/24 för 254
/25 för 126
/26 för 62
/31 för två routrar

### 9 Privat eller inte 
Vilka av adresserna är privata enligt RFC 1918: För de som inte är det – vad är de i stället?
172.32.5.1, Detta är inte privat då ramen är: 172.16.0.0 - 172.31.255.255
offentligt IP som kan användas av företag som exempel utan behov för koordination med IANA eller internet registry(IR)
172.31.200.9,Privat
10.255.0.1, privat
192.169.0.1, Offentligt då ramen för privat är 192.168.0.0 - 192.168.255.255
100.64.3.4, offentligt (rättat shared address space)
192.0.2.10? offentligt (rättat documentation)


### 10 Tillgångar och zoner


| tillgång | klass(låg, medel, hög) | Zon |
|---:|---:|---:|
| Publik webbserver | Medel | 10.40.44.0/23 |
| applikationsserver | medel | 10.40.46.1/24 |
| kunddatabas med personuppgifter loggserver | hög | 10.40.47.1/29 |
| jump-server för administration | hög | 10.40.47.17/28 |
| loggserver | hög | 10.40.47.19/28 |
| 30 arbetsplatser | låg | 10.40.47.65/27 |

Missade:
DMZ: webbservern
applikation: applikationsservern
data:kunddatabasen
drift och förvaltning: jump servern
klienter: arbetsplatserna

Misstog detta mot IP addresser

Man ska inte sätta databaser eller segment som har känslig information tillsammans med publika nätverk som kan skapa en attackyta av olika slag. genom segmentering behöver attackeraren gå igenom flera segment för att ta sig till vart den vill vilket kan öka möjligheten för att fånga viktig information om attacken.

