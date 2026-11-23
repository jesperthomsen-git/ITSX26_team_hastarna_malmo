# Subnetting

## Subnätstabell

| Prefix | Antal delar av ett /24 | Adresser per del |
|---|---:|---:|
| /18 | 64.0 | 16384 |
| /19 | 32.0 | 8192 |
| /20 | 16.0 | 4096 |
| /21 | 8.0 | 2048 |
| /22 | 4.0 | 1024 |
| /23 | 2.0 | 512 |
| /24 | 1 | 256 |
| /25 | 2 | 128 |
| /26 | 4 | 64 |
| /27 | 8 | 32 |
| /28 | 16 | 16 |
| /29 | 32 | 8 |
| /30 | 64 | 4 |


| Mask värde | Prefix bits |
|---:|---:|
| 0 | 0 |
| 128 | 1 |
| 192 | 2 |
| 224 | 3 |
| 240 | 4 |
| 248 | 5 |
| 252 | 6 |
| 254 | 7 |
| 255 | 8 |

Om 3:e oktetten används = -1 i total summan av oktetten
t.ex 10.40.150.10/22
/22 har 4 delar 
148-152, -1
148-151.255


antalet delar multipliceras med 2 och adresser per del divideras med 2. efter uträkning används 2 addresser per del reserverade 

Så /27 som har 8 delar har 16 addresser reserverade totalt med 30 oreserverade addresser i var del

uträkning: (8 × 2)totalet antal reserverade addresser
(8 × 30) 240 användbara adresser (alltid ta bort 2 från totala addresser per del, om det står 32 i tabellen så ska det vara 30, om 16 står så ska det vara 14 osv.)


## Sju attributer:
* Network ID (Net ID) - första addressen i vart subnät
* Broadcast IP (BC IP) - sista addressen i vart subnät -1
* First Host IP - första möjliga IP efter Net ID
* Last Host IP - sista möjliga IP innan BC IP
* Next Network - första möjliga IP efter BC IP
* IP Addresses - totalen av alla IP addresser i en sub
* CIDR/Subnet - identifierar storleken av en sub

## Cidr --> Subnät
/25 --> 255.255.255.128
/25 har 2 delar, 256/2 = 128

/27 har 8 delar, 256/8 = 32
Ta delarna och ta bort det från totalen /24=256:
256 - 32 = 224 = Subnät är 255.255.255.224


## Net ID & BC IP
Net ID: kan vara 10.0.0.0 
BC IP: kan vara 10.0.0.127 i ett /25 sub

på privat nätverk kan det se ut 192.168.1.0 & 127 allt imellan är användbara addresser 128 addresser i /25 men bara 126 finns tillgängliga

## Cheat sheet
Starta med 1 och sedan dubbla tills du når 128
ta bort talet du får med 256 = antalet addresser per del

1 är alltid /32
128		64		32		16 	8 	4 	2 	1
/25		/26		/27		/28	/29	/30	/31	/32
128		192		224		240	248	252	254	255

/18-/23 räknas som t.ex /21 = 0, 8, 16, 24, 32, 40, 48, 56

allt över /24 räknas med division:
/28 = 16 delar
8bits=256
256/16 = 16
16-2=14