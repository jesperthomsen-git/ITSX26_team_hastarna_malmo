# Härdningsrapport elev-10, vecka 7

## 1. Härdningslista

1. SELinux i Enforcing nu och efter omstart. Verifierat med getenforce, sestatus
   och grep ^SELINUX= /etc/selinux/config. Skript: ja.
2. zonvakt kör under en egen tvingande policy (zonvakt_t, utan permissive).
   Verifierat med ps -eZ och echo overtrad. Skript: ja.
3. /srv/zonwebb har typen httpd_sys_content_t via semanage fcontext och
   restorecon. Verifierat med ls -Zd och semanage fcontext -l -C. Skript: ja.
4. Paketfiltret släpper in ctf-servern (172.20.1.10) på tcp/80 och tcp/7510.
   Verifierat med sudo nft list chain inet zon in. Skript: nej (kräver sudo).

## 2. Härdningsrapport (utkast från AI, dömt mot servern)

### Påstående 1
SELinux är aktiverat och står i läget Enforcing just nu.
**Dom:** stämmer
**Kommando:** sestatus
**Utfall:** SELinux status: enabled, Current mode: enforcing

### Påstående 2
SELinux är konfigurerat att starta i Enforcing efter omstart.
**Dom:** stämmer
**Kommando:** sestatus (och grep ^SELINUX= /etc/selinux/config)
**Utfall:** Mode from config file: enforcing

### Påstående 3
Tjänsten zonvakt kör i den egna domänen zonvakt_t.
**Dom:** stämmer
**Kommando:** ps -eZ | grep zonvakt
**Utfall:** system_u:system_r:zonvakt_t:s0 1009 ? 00:00:00 zonvakt

### Påstående 4
Policymodulen zonvakt är laddad.
**Dom:** stämmer
**Kommando:** sudo semodule -l | grep zonvakt
**Utfall:** zonvakt

### Påstående 5
Domänen zonvakt_t är inte permissiv. Alla överträdelser stoppas och loggas.
**Dom:** delvis fel (stoppas, men loggas inte alltid)
**Kommando:** sudo semanage permissive -l
**Utfall:** zonvakt_t finns inte i listan, så domänen är inte permissiv. Men
vissa nekanden loggades inte (se rättelseloggen).

### Påstående 6
Katalogen /srv/zonwebb har typen httpd_sys_content_t.
**Dom:** stämmer
**Kommando:** ls -Zd /srv/zonwebb
**Utfall:** unconfined_u:object_r:httpd_sys_content_t:s0 /srv/zonwebb

### Påstående 7
Typen på /srv/zonwebb sätts av en bestående regel, så den tål en relabel.
**Dom:** stämmer
**Kommando:** sudo semanage fcontext -l -C
**Utfall:** /srv/zonwebb(/.*)? all files system_u:object_r:httpd_sys_content_t:s0

### Påstående 8
Tjänsten zonvakt kan inte skriva till /etc. Vid overtrad blir den nekad och
ingen fil skapas.
**Dom:** stämmer
**Kommando:** echo overtrad | nc -w2 127.0.0.1 7510, och ls
/etc/zonvakt-otillaten
**Utfall:** "zonvakt elev-10 nekad: Permission denied", och filen finns inte
(No such file or directory)

### Påstående 9
Paketfiltret släpper bara in ctf-servern, bara på tcp/80 och tcp/7510.
**Dom:** fel
**Kommando:** sudo nft list chain inet zon in
**Utfall:** se rättelseloggen

### Påstående 10
Verifieringsskriptet kontrollerar fyra saker och avslutar med felkod 0 när allt
gäller, även efter omstart.
**Dom:** stämmer
**Kommando:** /usr/local/bin/verifiera-hardning; echo "felkod: $?"
**Utfall:** fyra rader GÄLLER och felkod: 0 (körd efter omstart)

## 3. Rättelselogg

| Del | Påstående 5 | Påstående 9 |
|---|---|---|
| Påstående (kort) | Alla överträdelser stoppas och loggas | Paketfiltret släpper bara in ctf på tcp/80 och tcp/7510 |
| Dom | delvis fel | fel |
| Kommando som avgjorde | sudo semanage permissive -l, och sudo ausearch -m avc -c zonvakt före och efter semodule -DB | sudo nft list chain inet zon in |
| Faktiskt utfall | zonvakt_t är inte permissiv, så överträdelser stoppas. Men ausearch gav <no matches> trots att tjänsten kraschade. Med semodule -DB visades nekanden för read och write på tcp_socket. Alltså loggas inte alla. | 172.20.1.10 släpps in på tcp/22, tcp/25035, tcp/80 och tcp/7510. Jump (172.20.1.2) släpps in på tcp/22 och 10.40.4.10 på tcp/8080 via eth2. Allt annat stoppas av policy drop. |
| Feltyp | ogrundat | ogrundat |
| Ändrat till | zonvakt_t är inte permissiv. Överträdelser stoppas, men inte alla loggas, eftersom dontaudit-regler döljer vissa. | Paketfiltret har policy drop och släpper bara in listade källor och portar. ctf-servern släpps in på tcp/22, tcp/25035, tcp/80 och tcp/7510. |

**Öppen punkt:** min policy använder corecmd_exec_bin. Lösningsförslaget till
Ö9 säger att corecmd_mmap_bin_files räcker och är snävare. Jag har inte testat
det på min server än.

## 4. zonvakt.te

```text
policy_module(zonvakt, 1.0.0)

type zonvakt_t;
type zonvakt_exec_t;
init_daemon_domain(zonvakt_t, zonvakt_exec_t)

type zonvakt_log_t;
logging_log_file(zonvakt_log_t)

allow zonvakt_t self:fifo_file rw_fifo_file_perms;
allow zonvakt_t self:unix_stream_socket create_stream_socket_perms;

manage_dirs_pattern(zonvakt_t, zonvakt_log_t, zonvakt_log_t)
manage_files_pattern(zonvakt_t, zonvakt_log_t, zonvakt_log_t)
manage_lnk_files_pattern(zonvakt_t, zonvakt_log_t, zonvakt_log_t)
logging_log_filetrans(zonvakt_t, zonvakt_log_t, { dir file lnk_file })

domain_use_interactive_fds(zonvakt_t)
files_read_etc_files(zonvakt_t)
miscfiles_read_localization(zonvakt_t)

allow zonvakt_t self:tcp_socket { accept bind create getattr listen setopt };
corecmd_exec_bin(zonvakt_t)
corenet_tcp_bind_generic_node(zonvakt_t)
corenet_tcp_bind_generic_port(zonvakt_t)
auth_read_passwd_file(zonvakt_t)
allow zonvakt_t self:tcp_socket { read write };
```

Raden `permissive zonvakt_t;` är borttagen. files_manage_etc_files ingår inte.

## 5. zonvakt.fc

```text
/usr/local/bin/zonvakt          --      gen_context(system_u:object_r:zonvakt_exec_t,s0)

/var/log/zonvakt(/.*)?          gen_context(system_u:object_r:zonvakt_log_t,s0)
```

## 6. Verifieringsutdata (efter omstart)

```text
sestatus: Current mode: enforcing, Mode from config file: enforcing
sudo semodule -l | grep zonvakt: zonvakt
ps -eZ | grep zonvakt: system_u:system_r:zonvakt_t:s0 1009 ? 00:00:00 zonvakt
verifiera-hardning:
  GÄLLER: SELinux är i Enforcing just nu
  GÄLLER: /etc/selinux/config säger SELINUX=enforcing (efter omstart)
  GÄLLER: zonvakt kör i domänen zonvakt_t
  GÄLLER: /srv/zonwebb har typen httpd_sys_content_t
felkod: 0
```