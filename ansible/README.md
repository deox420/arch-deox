# ansible/ — provisioning idempotente (alternativa a install.sh)

Configura el sistema de forma declarativa. Mismo resultado que `install.sh`
pero con roles idempotentes.

## Estructura

```
ansible/
├── requirements.yml     # colecciones (community.general, kewlfft.aur)
├── inventory.ini        # localhost (connection=local)
├── group_vars/all.yml   # usuario, servicios, flags (install_pentest…)
├── site.yml             # playbook principal
└── roles/
    ├── base/            # pacman update + paquetes nativos + servicios
    ├── aur/             # bootstrap paru + paquetes AUR
    ├── dotfiles/        # chezmoi init --apply
    └── pentest/         # grupos BlackArch (opcional, guarded)
```

Las listas de paquetes se leen de `packages/pkglist-*.txt` (las mismas que usa
`install.sh`).

## Uso (en el Arch destino)

```bash
# 1) Colecciones (una vez)
ansible-galaxy collection install -r ansible/requirements.yml

# 2) Provisionar (pide la contraseña de sudo)
ansible-playbook -i ansible/inventory.ini ansible/site.yml --ask-become-pass

# Ensayo sin cambios:
ansible-playbook -i ansible/inventory.ini ansible/site.yml --check --ask-become-pass

# Con capa de pentest (revisa blackarch_groups en group_vars/all.yml):
ansible-playbook -i ansible/inventory.ini ansible/site.yml -K -e install_pentest=true
```

> El rol `pentest` NO ejecuta `strap.sh` (requiere verificar el sha1). Añade el
> repo BlackArch con `pentest/install-blackarch.sh` y luego corre el rol.

## install.sh vs ansible

Ambos hacen lo mismo; usa el que prefieras. `install.sh` no necesita Ansible;
los playbooks son más declarativos y fáciles de extender por roles.
