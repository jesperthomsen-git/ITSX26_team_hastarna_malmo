TILLGÅNGSFÖRTECKNING
====================

Namn: jump
Roll: Jumpserver för åtkomst till labbmiljön och vidare anslutning till labbservern.
Intern IP-adress: 172.20.1.2 (eth1)
Tjänster/portar: SSH – TCP/22

Belägg:
- "hostname" verifierade namnet jump.
- "ip a" visade 172.20.1.2 på eth1.
- "ss -tulpn" visade att servern lyssnar på TCP/22.
- "Last login" på elev-35 samt tcpdump visade SSH-trafik från jump (172.20.1.2) till elev-35 (172.20.1.135) på TCP/22.


--------------------------------------------------


Namn: elev-35
Roll: Teamets labbserver med SSH-åtkomst och webbtjänst för ITSX26 kurs 2.
Intern IP-adress: 172.20.1.135 (eth1)
Tjänster/portar:
- SSH – TCP/22
- HTTP/Apache 2.4.62 – TCP/80

Belägg:
- "hostname" verifierade namnet elev-35.
- "ip a" visade 172.20.1.135 på eth1.
- "ss -tulpn" visade att servern lyssnar på TCP/22 och TCP/80.
- "sudo ss -tulpn | grep ':80'" visade att httpd lyssnar på TCP/80.
- "curl -i http://localhost" gav HTTP/1.1 200 OK och visade Apache/2.4.62 (Rocky Linux).
- tcpdump verifierade SSH på TCP/22 och HTTP på TCP/80 mellan jump och elev-35. HTTP-fångsten visade "GET / HTTP/1.1" och svaret "HTTP/1.1 200 OK".


SAMMANFATTNING
==============

Vi har identifierat två tillgångar: jump (172.20.1.2) och elev-35 (172.20.1.135).

Jump används för SSH-åtkomst till labbmiljön på TCP/22. Elev-35 är teamets labbserver och erbjuder SSH på TCP/22 samt en Apache-webbtjänst på HTTP TCP/80.

Uppgifterna har verifierats med hostname, ip a, ss, curl och tcpdump.