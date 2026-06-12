# system/ — configuraciones de SISTEMA (van a /etc, no a tu home)

chezmoi solo gestiona tu `$HOME`. Los ficheros de esta carpeta son **de sistema**
(`/etc/...`) y se copian a mano con `sudo`. Se guardan aquí para que el entorno
siga siendo **reproducible** (si reinstalas, sabes exactamente qué poner y dónde).

## greetd-config.toml → `/etc/greetd/config.toml`
Gestor de inicio (login en modo texto con **tuigreet**) que arranca Hyprland al encender.

**Instalar:**
```bash
sudo pacman -S greetd greetd-tuigreet
sudo install -Dm644 ~/.local/share/chezmoi/system/greetd-config.toml /etc/greetd/config.toml
sudo systemctl enable greetd.service
reboot
```

**Importante:** greetd toma la VT1 al arrancar. Si alguna vez la config falla y no
puedes entrar, pulsa **Ctrl+Alt+F2** para ir a otra consola de texto, inicia sesión
ahí y corrige (`sudo systemctl disable greetd` para volver al arranque manual).
