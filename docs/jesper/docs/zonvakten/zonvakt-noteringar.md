# Reflektioner DevSecOps

########################################
# Setopt
| Del      | Fråga                                   | svar |
| -------- | --------------------------------------- | ---- |
| Åtgärd   | Vad ändrade jag?                        | allow zonvakt_t self:tcp_socket { create setopt}; |
| Skäl     | Varför gör det systemet säkrare?        | tillåter zonvakt_t att använda sig av setops genom SO_REUSEADDR, behåller skriptet funktionellt |
|Kontroll  | Hur bevisar jag att ändringen fungerar? | enligt avc slutade felmeddelanden att komma in och python skript fungerar |

## kommentar
anmärknisvärt var att SO_REUSEADDR var kallad genom Python's setsockopt() som skapade problem i python
 skriptet när jag försökte kalla på zonvakten. Zonvakten försökte starta 5 gånger innan SElinux blockerade den helt enligt avc.
 i loggen står det tydligt denied { setopt } som faller tillbaka till python scriptets TCP förnyelse. Är denna nödvändig för zonvakten?
 Nej, inte direkt då den endast underlättar om zonvakten startar om efter bindningen av ip och port och lyssnar.
 Är den essentiell för att skriptet ska fungerar utan problem? Ja, enligt python skriptet i def main() finns denna kod:

namn, port = las_konf()
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    s.bind(("0.0.0.0", port))
    s.listen(5)
    logga(f"startar namn={namn} port={port}")
setsockopt() försöker aktivera SO_REUSEADDR.

* Python skapar en TCP-socket. Mm SELinux nekar operationen och Python får ett OSError, avbryts main() eftersom felet inte fångas
med try/exception OSError.
* Python skapar en TCP-socket.
* Programmet når då aldrig bind() eller listen(). om setopt nekas

## koppling till least priv:
* Är SO_REUSEADDR livsviktigt för en TCP-server? Nej. En TCP-server kan fungera utan det
* Är setopt nödvändigt för att köra lärarens befintliga kod oförändrad? Ja, eftersom koden förväntar sig att anropet lyckas.
* Systemd försöker starta om tjänsten enligt dess Restart=-inställning men stoppar efter sin startbegränsning

########################################
# Getattr
| Del      | Fråga                                   | Svar |
| -------- | --------------------------------------- | ---- |
| Åtgärd   | Vad ändrade jag?                        | Lade till getattr i allow zonvakt_t self:tcp_socket { create getattr setopt }; |
| Skäl     | Varför gör det systemet säkrare?        | getattr tillåter Zonvakt att läsa attribut från sin egen TCP-socket utan att ge fil- eller nätverksbehörigheter. Regeln följer least privilege om behörigheten faktiskt behövs. |
| Kontroll | Hur bevisar jag att ändringen fungerar? | Kontrollera att relevanta AVC-nekanden för getattr upphör och jämför tjänstens beteende före och efter ändringen. Inte bevisat än att getattr ensamt löser startproblemet. |

## Kommentar

SELinux behöver getattr – varför behöver Zonvakt det?
I AVC-loggarna har jag observerat:
denied { getattr } för zonvakt_t på self:tcp_socket.

getattr betyder "get attributes" och tillåter en process att läsa attribut eller information om ett objekt.
I detta fall gäller behörigheten Zonvakts egen TCP-socket.

Tidigare AVC-loggar visade getattr-nekanden i samband med
systemanropen getsockname() och getpeername().
Dessa används för att hämta information om socketens lokala respektive fjärranslutna adress.

I journalen hittade jag följande:

File "/usr/local/bin/zonvakt", line 39, in main
     s.bind(("0.0.0.0", port))
PermissionError: [Errno 13] Permission denied
Detta visar att Python avslutades när bind() nekades.


I auditloggen identifierades:
'syscall=49'
'exit=-13'
syscall 49 motsvarar bind() på x86_64 Linux.
exit=-13 betyder EACCES (Permission denied).

Detta bevisar att bind-operationen misslyckades. Det bevisar däremot inte att getattr orsakade felet.
Jag har även identifierat separata SELinux-nekanden för: bind, name_bind och node_bind genom för att hitta deras
t.ex seinfo -a node_type -x

Därför måste dessa kontroller undersökas separat.
* Är getattr nödvändigt för att skapa en TCP-socket? Nej, create och getattr är olika SELinux-behörigheter.
* Är getattr nödvändigt för att använda bind()? Inte generellt. bind() kontrolleras av andra behörigheter.
* Är getattr nödvändigt för att Zonvakt ska fungera? Det är ännu inte slutgiltigt bevisat.
Loggarna visar att behörigheten har nekats, men vi behöver undersöka om nekandet påverkar tjänstens normala funktion.

## Koppling till least privilege:

### Regeln:
allow zonvakt_t self:tcp_socket { create getattr setopt };
Begränsar getattr till TCP-socketar som tillhör samma SELinux-domän som Zonvakt.
Den ger inte Zonvakt rätt att läsa godtyckliga filer eller skriva till /etc/zonvakt-otillaten.
Däremot ska vi inte lägga till en behörighet enbart för att ett AVC-meddelande förekommer.

## Slutsats:

Under felsökningen har jag undersökt SELinux-behörigheter genom att jämföra AVC-loggar med Pythons traceback och tjänstens faktiska beteende.
Jag har kunnat verifiera att Zonvakt behöver behörigheterna listen, accept, read och write på sina TCP-socketar för att kunna ta emot anslutningar, läsa meddelanden och skicka svar.
Jag har även undersökt getattr, där ett negativt test visade att ett nekande vid getpeername kunde stoppa tjänsten.

Positivt funktionstest:
hej → zonvakt elev-43 ok

Negativt säkerhetstest:
overtrad → zonvakt elev-43 nekad: Permission denied

Samtidigt förekommer nekanden för åtkomst till SSSD och /etc/passwd. Eftersom dessa inte hindrade de verifierade funktionerna har jag inte lagt till några extra behörigheter för dem.
* Jag har lärt mig att ett AVC-nekande inte automatiskt innebär att en behörighet ska tillåtas. Varje ändring bör motiveras med loggar, funktionstester och principen least privilege.
Zonvakt fungerar nu lokalt med SELinux i enforcing-läge och blockerar den otillåtna filskrivningen. Anslutning från jumpservern återstår att verifiera.

########################################
# Listen

| Del      | Fråga                                   | Svar |
| -------- | --------------------------------------- | ---  |
| Åtgärd   | Vad ändrade jag?                        | Lade till `listen` i `allow zonvakt_t self:tcp_socket { create getattr setopt bind listen };` |
| Skäl     | Varför gör det systemet säkrare?        | Tillåter Zonvakt att lyssna på sin egen TCP-socket utan att ge bredare behörigheter. |
| Kontroll | Hur bevisar jag att ändringen fungerar? | AVC-loggen visar `denied { listen }` och Python kraschar vid `s.listen(5)`. Efter installation behöver jag verifiera att nekandet upphör och tjänsten startar. |

## Kommentar

Jag jämförde AVC-loggen med Pythons traceback och kunde bekräfta att SELinux nekade systemanropet `listen`, vilket orsakade `PermissionError` på rad 40.

Till skillnad från `getattr` har jag därför kunnat bevisa att `listen` behövs för att Zonvakts skript ska fungera.

Behörigheten begränsas till Zonvakts egna TCP-socketar enligt principen least privilege.

## Undersökning:

Jag jämförde Pythons traceback med kommandot sudo journalctl -u zonvakt.service -n 40 --no-pager |grep -A 6 'Traceback' för att förstå varför Zonvakt kraschade.

Nov 19 14:53:32 elev-43 zonvakt[43228]: Traceback (most recent call last):
Nov 19 14:53:32 elev-43 zonvakt[43228]:   File "/usr/local/bin/zonvakt", line 64, in <module>
Nov 19 14:53:32 elev-43 zonvakt[43228]:     main()
Nov 19 14:53:32 elev-43 zonvakt[43228]:   File "/usr/local/bin/zonvakt", line 40, in main
Nov 19 14:53:32 elev-43 zonvakt[43228]:     s.listen(5)
Nov 19 14:53:32 elev-43 zonvakt[43228]: PermissionError: [Errno 13] Permission denied
Nov 19 14:53:32 elev-43 systemd[1]: zonvakt.service: Main process exited, code=exited, status=1/FAILURE

SELinux avc logg:
avc: denied { listen }
scontext=system_u:system_r:zonvakt_t:s0
tcontext=system_u:system_r:zonvakt_t:s0
tclass=tcp_socket
permissive=0

# Slutsats:

Loggarna visar att `bind()` hade passerats och att Python nådde `listen()`, där SELinux nekade behörigheten(koppling till getattr?).
Eftersom `listen()` krävs för att en TCP-server ska kunna ta emot anslutningar är behörigheten nödvändig för Zonvakts funktion.
Regeln `allow zonvakt_t self:tcp_socket listen;` är därför motiverad enligt *least privilege*, eftersom den begränsas till TCP-socketar inom Zonvakts egen SELinux-domän.