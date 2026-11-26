# Seguridad de lo que se instala

Pediste: *"comprueba siempre que cualquier cosa que vayas a instalar esté disponible, no tenga
vulnerabilidades conocidas y esté al día"*. Así se cumple en este kit.

## 1. Solo fuentes oficiales y verificadas
- **Todo** sale del repositorio oficial `kali-rolling`. Nada de PPAs, repos de terceros,
  `curl | sh`, binarios sueltos ni compilar desde GitHub.
- apt comprueba la **firma GPG** de Kali en cada actualización.
- La **ISO** se verifica con la clave oficial de Kali
  (`827C 8569 F251 8CC6 77FE CA1A ED65 462E C8D5 E4C5`, en vigor hasta 2028) y su SHA256.
  Si la firma no es válida o el hash no coincide, el script aborta y la borra.
- `10-sistema.sh` avisa si hay repos de Debian/Ubuntu mezclados (rompen Kali).

## 2. Auditoría antes de CADA instalación: `deox-auditar`
Cada bloque de los scripts (`instalar_auditado` en `scripts/lib.sh`):
1. comprueba que todos los paquetes **existen** en el repo;
2. simula la instalación (con dependencias) y la cruza con el
   **[Debian Security Tracker](https://security-tracker.debian.org/tracker/)**;
3. te enseña el resultado y **pregunta** antes de instalar.

El resultado se lee así:

| Etiqueta | Significado | Qué hacer |
|---|---|---|
| `[ACTUALIZA YA]` | Hay un arreglo publicado en Kali y tienes una versión vieja. | `sudo apt full-upgrade` |
| `[EN CAMINO]` | Debian ya lo arregló, pero Kali aún no lo ha publicado (suele tardar días). | Nada: llega solo actualizando. |
| `[SIN PARCHE]` | CVE conocido que nadie ha arreglado aún (ni Debian ni el autor). | Informativo. |

Úsalo cuando quieras: `deox-auditar` (lo instalado) o `deox-auditar --simular paquete`
(lo que instalaría). `40-seguridad.sh` programa un aviso **semanal**.

> Límite honesto: los ~1.400 paquetes **exclusivos de Kali** (las herramientas con
> `-0kaliN` en la versión: nuclei, netexec, bloodhound…) no están en el tracker de Debian.
> Para esos la garantía es que Kali los empaqueta y actualiza desde el proyecto original;
> mantenlos al día con `apt full-upgrade`.

## 3. Resultado de la auditoría al preparar este kit (26-nov-2026)

Simulación en un Kali real (chroot `kali-rolling`, índice verificado con la firma de Kali),
instalando `kali-linux-default` + las tres listas del repo, con dependencias y recomendados
(≈ 2.470 paquetes):

- **Todos** los nombres de `packages/*.txt` existen y se resuelven sin conflictos (también
  con `kali-linux-large`).
- `[ACTUALIZA YA]`: **0**.
- Lo que añadían **nuestras listas** con CVEs pendientes, y lo que se hizo:

  | Paquete | Por qué entraba | Decisión |
  |---|---|---|
  | `exim4` (servidor de correo) | "recomendado" de timeshift/debsecan | **Excluido** (`exim4-…-` en `lib.sh`): un servicio de red que no necesitas |
  | `libmodplug1` (CVEs sin arreglar en Kali) | recomendado de blueman | **Excluido** |
  | `mpv` | reproductor | **Quitado** de la lista |
  | `udiskie` (→ `libblockdev`) | montar USBs | **Quitado**; Thunar monta USBs igual |
  | `needrestart` (1 CVE pendiente) | utilidad | **Quitado** |
  | `debsecan` | auditor | **Sustituido** por `deox-auditar` |
  | `radare2` (30 CVE "en camino") | extra de reversing | **Quitado** de extras (lo trae igualmente `kali-linux-default`) |
  | `xwayland` (7 CVE, urgencia *unimportant*) | necesario para apps Java/X11 (Burp, Ghidra, ZAP) | **Se mantiene**; arreglo en camino |

- El resto de avisos `[EN CAMINO]` (~40 paquetes: kernel, Chromium, Firefox ESR, Wireshark,
  PostgreSQL, ImageMagick…) vienen del propio **`kali-linux-default`**: son el desfase normal de
  unos días entre Debian y Kali y se arreglan con `apt full-upgrade`. Por eso `10-sistema.sh`
  empieza siempre con una actualización completa.

## 4. Tu portátil también es un objetivo
`40-seguridad.sh`:
- **ufw**: deniega todo lo entrante. Para una reverse shell abre el puerto **solo en la VPN**
  y ciérralo al terminar (`sudo ufw allow in on tun0 to any port 4444 proto tcp`).
- Revisa qué servicios escuchan en la red (Kali los deja desactivados; que siga así).
- **AppArmor** activo.
- Recomendado en la instalación: **disco cifrado (LVM + LUKS)**.
- Las copias de seguridad guardan claves y contraseñas wifi **cifradas** (AES-256).

## 5. Uso legal
Las herramientas de Kali son para **sistemas propios o con permiso por escrito**: CTFs,
laboratorios (HackTheBox, TryHackMe, VulnHub), auditorías contratadas. Usarlas contra
terceros sin autorización es delito (en España, arts. 197 bis y 264 del Código Penal).
