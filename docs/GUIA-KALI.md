# Guía paso a paso: de CachyOS a Kali (kali-deox)

Pensada para alguien nuevo en Linux. Tiempo total: **2–3 horas** (casi todo es esperar).

Necesitas:
- El portátil **enchufado** a la corriente.
- Un **disco externo o pendrive grande** para la copia de tus datos.
- Un **pendrive de 8 GB o más** para instalar Kali (se borrará entero). Debe ser OTRO distinto
  del de la copia.
- Internet.

---

## Parte 1 · En tu CachyOS actual (≈ 45 min)

1. Abre una terminal y ve al repo (o clónalo):
   ```bash
   cd ~/arch-deox && git pull
   # si no lo tienes:  git clone https://github.com/deox420/arch-deox.git ~/arch-deox && cd ~/arch-deox
   ```
2. Conecta el **disco de la copia** (se monta solo en `/run/media/deox/…`).
3. Lanza el asistente:
   ```bash
   bash migrar.sh
   ```
   Te guiará por tres pasos y te preguntará antes de cada cosa:

   | Paso | Qué hace | Qué tienes que hacer tú |
   |---|---|---|
   | **1 · Copia** | Copia Documentos, Imágenes, Descargas, Música, Vídeos… y comprueba cada fichero con una suma SHA256. Tus **claves SSH/GPG, redes wifi y perfil de Firefox** van en `secretos.tar.gpg`, **cifrado con AES-256**. | Escribir la ruta del disco y **elegir una contraseña** para el cifrado. **Apúntala en papel.** |
   | **2 · ISO** | Descarga la última Kali (~5 GB), comprueba la **firma oficial de Kali** (huella `827C 8569 F251 8CC6 77FE CA1A ED65 462E C8D5 E4C5`) y el hash. Si algo no cuadra, la borra. | Esperar. |
   | **3 · USB** | Graba la ISO en el pendrive y la **verifica byte a byte**. Se niega a tocar el disco del sistema o el de la copia. | Meter el pendrive y **escribir su nombre** (ej. `sdb`) para confirmar. |

   > ¿Algo se corta? Vuelve a lanzar `bash migrar.sh`: recuerda dónde ibas.
   > También puedes ir paso a paso: `bash migracion/migrar-desde-cachyos.sh copia|iso|usb`.

## Parte 2 · Instalar Kali (≈ 30 min)

1. Con el pendrive puesto, **reinicia** y pulsa la tecla del menú de arranque (en Medion suele
   ser **F10** u **F11**; si no aparece, entra en la BIOS con **F2** y pon el USB primero).
   Si dice algo de *Secure Boot*, desactívalo en la BIOS.
2. Elige **Graphical install** y responde:
   - Idioma **Español**, país **España**, teclado **Español**.
   - Nombre del equipo: `kali-deox`. Usuario: `deox` (y una contraseña buena).
   - Particionado: **Guiado – utilizar todo el disco y configurar LVM cifrado**.
     Te pedirá una frase de cifrado: si te roban el portátil, nadie podrá leer nada.
     ⚠ Esto **borra el disco**. Por eso hiciste la copia.
   - Software: marca **Xfce** (escritorio de reserva, por si algo falla) y
     **default tools** (o desmárcalo y elige luego en el paso 30, con más opciones).
   - Instalar GRUB en el disco principal: **sí**.
3. Al terminar, quita el pendrive y reinicia.

## Parte 3 · Primer arranque en Kali (≈ 1 h, casi todo descargas)

Entrarás en Xfce. Abre **Terminal** y:
```bash
sudo apt update && sudo apt install -y git
git clone https://github.com/deox420/arch-deox.git ~/kali-deox
cd ~/kali-deox
bash migrar.sh
```
(¿Sin internet? Conecta el disco de la copia y clona desde ahí:
`git clone /media/deox/<disco>/kali-deox-migracion/info/kali-deox-repo.bundle ~/kali-deox`)

El asistente (`scripts/bootstrap.sh`) va por bloques y **siempre pregunta**:

1. **Sistema** – comprueba repos, actualiza todo, drivers Intel, español.
2. **Escritorio** – Hyprland + barra + lanzador + login nuevo. Valida la configuración.
3. **Hacking** – elige `kali-linux-default` (~12 GB) o `kali-linux-large` (~21 GB) y extras.
4. **Seguridad** – cortafuegos, AppArmor, aviso semanal de actualizaciones.
5. **Snapshots** – una "foto" del sistema para volver atrás si algo se rompe.
6. **Tus datos** – restaura la copia (te pedirá la contraseña del cifrado).

Antes de instalar cada bloque verás una **auditoría de seguridad** (explicada en
[SEGURIDAD.md](SEGURIDAD.md)).

Reinicia (`sudo reboot`). En el login pulsa **Enter** → Hyprland. 🎉
Pulsa **`SUPER + F1`** para ver los atajos.

---

## Si algo va mal

| Problema | Solución |
|---|---|
| Pantalla negra / Hyprland no arranca | En el login pulsa **F3** y elige **Xfce**. Luego mira `Hyprland --verify-config`. |
| No aparece el login nuevo | `Ctrl+Alt+F2`, entra, y `sudo systemctl enable greetd` (o vuelve a lightdm: `sudo systemctl disable greetd && sudo systemctl enable lightdm`). |
| Una actualización rompió algo | `sudo timeshift --restore` (ver `scripts/50-snapshots.sh`). |
| La barra desapareció | `SUPER + SHIFT + W`. |
| Wifi no va | `nmcli device wifi list` y `nmcli device wifi connect "RED" --ask`. |
| Quiero cambiar algo de Hyprland | Edita `~/.config/hypr/usuario.lua` y `SUPER + SHIFT + R`. |

## Mantenimiento

- Actualiza **a menudo** (Kali es "rolling"): `actualizar` (alias de `sudo apt update && sudo apt full-upgrade`).
- Revisa vulnerabilidades: `deox-auditar`.
- Copia de tus datos: `bash scripts/60-copia.sh /run/media/deox/<disco>`.
- ¿Cambié algo de la configuración y lo quiero en el repo? `bash tests/verificar.sh` y commit.
