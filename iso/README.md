# iso/ — medio live de arch-deox (archiso)

ISO live personalizada basada en el perfil oficial **releng**, con mis paquetes
y un par de ayudantes para instalar Arch con mi config.

## Cómo está montado

No se versiona el boilerplate de archiso (cambia con la versión). En su lugar,
`build.sh` parte de `releng` y superpone:

| Capa | Qué hace |
|---|---|
| `packages.extra.x86_64` | paquetes que se añaden a los de releng |
| `airootfs/` | ficheros que se copian al sistema live (motd, `arch-deox-install`) |
| `build.sh` | ajusta `profiledef.sh` (nombre/label/permisos) y llama a `mkarchiso` |

Artefactos de build (`iso/work/`, `iso/out/`) están en `.gitignore`.

## Construir la ISO

> Solo desde **Arch** y con el paquete `archiso` instalado:
> `sudo pacman -S archiso`

```bash
./build.sh --dry-run   # muestra los pasos, no construye nada
./build.sh             # construye (mkarchiso pide sudo y tu confirmación)
# Resultado: iso/out/arch-deox-*.iso
```

## Usar la ISO (USB portátil con Ventoy)

1. Instala [Ventoy](https://www.ventoy.net) en tu USB.
2. Copia `iso/out/arch-deox-*.iso` a la partición de Ventoy (arrastrar y soltar).
3. Arranca desde el USB y elige la ISO en el menú de Ventoy.

### Persistencia (opcional)

Ventoy permite persistencia con un fichero de respaldo (`.dat`) asociado a la
ISO mediante un plugin (`ventoy.json` → `persistence`). Para Arch live hace falta
un blob de persistencia compatible; revisa la documentación de Ventoy
(*Persistence Plugin*) antes de configurarlo. Por defecto la ISO arranca sin
persistencia (cada arranque es limpio).

## En el entorno live

```bash
arch-deox-install        # lanza archinstall con mi user_configuration.json
```
Tras reiniciar al sistema instalado, sigue el README raíz (`./install.sh`).
