# Ö1. DAC eller MAC? En webbserver kör som användaren apache. En angripare tar över processen. Vad bestämmer vilka filer angriparen kommer åt i DAC, och vad bestämmer det i MAC? Varför skyddar MAC även när processen kör som root?

svar: 
enkelt sagt är DAC Discretionary access controll en kontroll som ägaren kan kontrollera som läs, skriv och exekverbar som begränsar vad apache kan komma åt.  
MAC är Mandatory access control som drivs av policys och regler som SELinux. MAC går genom policies som skyddar filer och mappar även om du är root utan direkt tillåtelse i policyn.

# Ö2. Lägena. Vad händer med en överträdelse i läget enforcing, permissive respektive disabled? Varför är disabled sämre än permissive även vid felsökning?

svar: Disabled gör att SELinux är avaktiverat, permissive är att den är igång men låter saker igenom även om policyn är där men loggar aktivitet och enforcing är när SELinux faktiskt är igång och kör enligt sina policys som är lagda

# Ö3. Nu och efter omstart. getenforce svarar Permissive men /etc/selinux/config säger SELINUX=enforcing. Vilket läge gäller efter nästa omstart? Hur kan det ha blivit så här?

svar: Det kommer vara enforcing nästa omstart. det kan vara att permissive är på just nu och ny policy har inte blivit lagd genom 'sudo make -f /usr/share/selinux/devel/Makefile zonvakt.pp'

# Ö4. Kontexten. Förklara de fyra fälten i system_u:object_r:httpd_sys_content_t:s0. Vilket fält avgör nästan alltid om åtkomst tillåts?

svar: 
system_u - SELinux användare
object_u - SELinux roll
httpd_sys_content_t - filens säkerhetstyp
s0 - säkerhetstyp

SELinux kontrollerar om en policy finns för httpd_t om den får läsa filer med typen httpd_sys_content_t

# Ö5. Läs en AVC. type=AVC msg=audit(1794500123.456:2881): avc: denied { name_bind } for pid=4711 comm="httpd" src=8088 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:unreserved_port_t:s0 tclass=tcp_socket permissive=0 Vilken process, vilken resurs och vilken operation nekades? Stoppades den eller loggades den bara? Vilken åtgärd är rätt?

svar: 
AVC: denied { name_bind } - visar vilken policy som blev nekad
comm="httpd" - processens namn
src=8088 - källport 8088
scontext=system_u:system_r:httpd_t:s0 - visar SELinux-kontexten för processen som blev nekad
tcontext=system_u:object_r:unreserved_port_t:s0 - SELinux-kontexten(typen) som scontext försöker använda 
tclass=tcp_socket - resursen som SELinux kontrollerar
permissive=0 - visar att denna regeln är enforced

Den stoppades helt och blev loggad via avc. Om man vill godkänna denna i policyn kan man skriva allow system_r:httpd_t object_r:unreserved_port_t name_bind; i policyn, sedan behöver man bygga om SELinux för att den nya regeln sparas och körs. alternativt sudo i konsolen utan att gå in i policyn "semanage port -a -t http_port_t -p tcp 8088".


# Ö6. Välj rätt åtgärd. För varje fall: fcontext, boolean, portmärkning eller egen policymodul?
1. httpd ska servera filer från /srv/intranat och ger 403. 
	svar: kontrollera fcontext, skapa avgränsning 
2. httpd ska vara proxy mot en applikationsserver på ett annat nät och får Permission denied vid anslutning. 
	svar: boolean för att kontrollera om policyn är av eller på sudo 'getsebool httpd_can_network_connect'
3. sshd ska lyssna på port 2222. 
	svar: portmätning, kontrollera med sudo 'semanage port -l | grep ssh_port_t' sedan skapa märkningen med 'sudo semanage port -a -t ssh_port_t -p tcp 2222'
4. En egen tjänst kör som unconfined_service_t. 
	svar: policymodul, kan skapa modul genom t.ex 'allow unconfined_service_t unconfined_service_t read;'


# Ö7. chcon eller semanage fcontext? Du rättar en katalog med chcon -t httpd_sys_content_t och allt fungerar. Veckan efter slutar det fungera. Vad hände, och hur borde du gjort?

svar: chon används för att ändra katalogens SELinux kontexter direkt men kan gå förlorat när man använder restorechon.
man kan skapa en regel utanför filen med semanage: "sudo semanage fcontext -a -t httpd_sys_content_t '/srv/web(/.*)?'"
Sedan kan man skriva 'sudo restorecon -Rv /srv/web' för att återställa reglerna och kontrollera om den nya regeln stannar kvar
chcon ändrar direkt i filen men ändrar inte reglerna för hur filen ska märkas.
semanage fcontext ändrar contexten och sparar en regel direkt och anger vilken märkning ska ha.


# Ö8. Permissiv domän eller permissivt system? Vad är skillnaden mellan setenforce 0 och raden permissive zonvakt_t; i en policymodul? Varför är den ena acceptabel under arbetet och den andra inte?

svar: genom att ha setenforce 0 gör her SELinux permissive och låter allt samt zonvakt attbli tillåtet. Att endast köra permissive på zonvakt gör att endast det som zonvakten gör blir godkänt, bra för felsökning. Setenforce 0 kan utsätta en för säkerhetsrisker.


# Ö9. Granska audit2allow. audit2allow -R föreslår för zonvakt bland annat corecmd_exec_bin, corecmd_mmap_bin_files, auth_read_passwd_file, corenet_tcp_bind_generic_port och files_manage_etc_files. Vilka rader behöver tjänsten, vilken ska absolut inte in, vilken är för bred – och vilken behövs inte alls?

svar: 
corecmd_exec_bin - endast om tjänsten inte kan fungera utan
corecmd_mmap_bin_files - nekas
auth_read_passwd_file - nekas
corenet_tcp_bind_generic_port - nekas för brett, kan avgränsas med 'sudo semanage port -a -t zonvakt_port_t -p tcp 7543'
files_manage_etc_files - nekas -för brett


# Ö10. Verifiering eller konfiguration? Ett "verifieringsskript" innehåller raden setenforce 1 && echo "SELinux: GÄLLER". Vad är problemet? Skriv om raden så att den verifierar.

svar: setenforce 1 ser till att du sätter SELinux som enforcing direkt. getenforce kan kontrollera statusen utan att ändra något.  

enkelt bash kommando kan vara:
[[ $(getenforce) == "Enforcing" ]] && printf "SELinux: GÄLLER\n" || printf "SELinux: INTE ENFORCING\n"
[[]] kontrollerar villkor
&& körs om sant
|| om falskt