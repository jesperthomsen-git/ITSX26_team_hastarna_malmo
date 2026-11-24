#| Del | Fråga | svar |
#|---|---|---|
#| Åtgärd |Vad ändrade jag? |---|
#| Skäl | Varför gör det systemet säkrare? |---|
#|Kontroll | Hur bevisar jag att ändringen fungerar? |--|



| Åtgärd                  | Skäl – vilket hot?                              | Kontroll                                |
| ----------------------- | ----------------------------------------------- | --------------------------------------- |
| SELinux Enforcing       | Hindrar otillåten åtkomst                       | 'getenforce' och 'sestatus'             |
| Egen policy för zonvakt | Hindrar tjänsten från att ändra otillåtna filer | 'ps -eZ | grep zonvakt' och test med 'echo overtrad | nc -w2 127.0.0.1 7543' |
| Begränsa öppna portar   | Minskar risken för obehöriga anslutningar       | 'nft list ruleset' och anslutningstest 'echo hej | nc -w2 127.0.0.1 7543' |
| Kontrollera port        | Ser till att porten är öppen                    | 'sudo ss -tlnp | grep 7507'              |
| Säkra SSH               | Minskar risken för obehörig inloggning          | 'sudo sshd -T | grep -E 'permitrootlogin|passwordauthentication' |


**Kom ihåg:** En säkerhetsåtgärd är inte verifierad bara för att du har skrivit ett kommando. Du behöver kontrollera resultatet

# REFLEKTIONSLISTAN, EGEN, VIKTIG
~/policy/zonvakt-noteringar.md


# REGLER
sudo nano ~/policy/zonvakt.te
head -n 25 /usr/local/bin/zonvakt
	#25 rader av specifik fil
grep -nE 'socket|datetime' /usr/local/bin/zonvakt
	#leta efter specifika regler från python script

# SELinux config
systemctl cat zonvakt

# kontrollera om type enforcement filer finns:
cat zonvakt.te zonvakt.fc

egen policy för zonvakt
mkdir ~/policy && cd ~/policy && sudo DNF_VAR_rltype= sepolicy generate --init -n zonvakt /usr/local/bin/zonvakt && sudo make -f /usr/share/selinux/devel/Makefile zonvakt.pp 

# läs vad som genererades
	cat zonvakt.te zonvakt.fc 

# ladda policyn
cd ~/policy && sudo make -f /usr/share/selinux/devel/Makefile zonvakt.pp && sudo semodule -i zonvakt.pp && sudo systemctl restart zonvakt && sleep 10 && sudo systemctl is-active zonvakt

# starta om zonvakten  
	sudo systemctl restart zonvakt
	sudo systemctl restart zonvakt && ps -eZ | grep zonvakt # nu zonvakt_t # startar om & kontroll

# uppdatera SELinux-kontexter
	sudo restorecon -Rv /usr/local/bin/zonvakt /var/log/zonvakt

# Kontrollerar status
	getenforce
	sestatus
	sudo semanage permissive -l | grep zonvakt #för att se om permissive är fortfarande på

# kontrollerar om policyn finns
	ls -Z /usr/local/bin/zonvakt
	sudo systemctl cat zonvakt | grep -E 'ExecStart=/usr/local/bin/zonvakt'
	seinfo -a node_type -x
	# seinfo visar SELinux policy, -a för attributer, typ av attribut, -x för utökad info


**********************************
# ausearch – Vad hände?
	sudo ausearch -m AVC,USER_AVC -ts recent -i
	sudo journalctl -u zonvakt.service -n 40 --no-pager |grep -A 10 'Traceback'

# audit2why – Varför hände det?
	sudo ausearch -m AVC -ts recent --raw | audit2why

# audit2allow – Vad skulle tillåta det?
	sudo ausearch -m AVC -ts recent --raw | audit2allow
	sudo ausearch -m avc -c zonvakt --raw | audit2allow -R
	# granskar förslagen tillsammans och skiljer mellan:
	#tillstånd som zonvakt behöver & tillstånd som skulle ge zonvakt otillåten åtkomst
	sudo ausearch -m avc -c zonvakt --raw | audit2allow -R > ~/policy/forslag.txt
	#skapar en textfil av hela audit2allow
	sudo ausearch -m AVC -c zonvakt -ts today --input-logs -i | tail -n 8
	#visar EN hel logg

# visar regler i policyn
* skapa numrerad lista med specifika grep stränger för filen ~/policy/zonvakt.te
	grep -nE 'permissive|allow |auth_|corecmd_|corenet_|files_|sssd_' ~/policy/zonvakt.te
*	#ssh serverns säkerhetsinställningar
	sudo sshd -T | grep -E 'permitrootlogin|passwordauthentication'
* processens SELinux-domän
	ps -eZ | grep httpd
* -A allow, -s sträng/sök efter specifik regel, -c begränsar, -p söker efter behörigheter som getattr
	**VIKTIG** sesearch -A -s zonvakt_t -c tcp_socket -p name_bind
* listar domäner som är satta inom permissive
	sudo semanage permissive -l | grep zonvakt

# ändra policy/regler
	sudo nano ~/policy/zonvakt.te
	t.ex corecmd_mmap_bin_files(zonvakt_t)
	sudo semanage port -a -t zonvakt_port_t -p tcp 7543
# sealert – Hur kan jag förstå och åtgärda problemet?
	sudo sealert -a /var/log/audit/audit.log | grep -E 'Sök'

**********************************

# felsök
sudo sesearch -T -s init_t -t zonvakt_exec_t -c process
	#visar regel som låter systemd(init_t) starta zonvakt
ps -eZ -p 1 | grep -E 'init_t'
	#visar om systemd faktiskt kör init_t. init_t startar zonvakten 
sudo systemctl show zonvakt -p SELinuxContext -p ExecStart
	#kontrollerar tjänstinställningar, ExecStart pekar vart?
	#"SELinuxContext="" visar vad?

grep ^SELINUX= /etc/selinux/config


- Välj 3–5 härdningsåtgärder tillsammans.
- Beskriv vilket hot varje åtgärd minskar.
- Beskriv hur varje åtgärd kontrolleras.
- Minst två åtgärder per person ska kunna verifieras med skript.
- SELinux måste vara Enforcing nu och efter omstart.

### **3. Exempel på verifiering med skript**

```
#!/bin/bash

if [ "$(getenforce)" = "Enforcing" ]; then
    echo "SELinux: GÄLLER"
else
    echo "SELinux: GÄLLER INTE"
fi
```

**Förklaring:** Skriptet läser SELinux-läget och visar om kravet är uppfyllt. Det ändrar inga inställningar.

### **4. Vad ska ni lämna in?**

En härdningslista som visar:

1. Vad ni har gjort.
2. Varför åtgärden behövs.
3. Hur ni kontrollerar resultatet.

Under workshopen ska ni också arbeta fram ett verifieringsskript för minst två åtgärder per person.

.

kommando = id
uid=1000(student) gid=1000(student) groups=1000(student),10(wheel)
context(SELinux)=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023

