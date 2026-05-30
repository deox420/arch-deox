# ansible/ — provisioning idempotente (opcional)

Alternativa/complemento a `install.sh` para configurar el sistema de forma
declarativa e idempotente. Aún sin playbooks.

Idea de estructura cuando se implemente:

```
ansible/
├── inventory.ini
├── site.yml            # playbook principal
└── roles/
    ├── base/           # paquetes nativos + servicios
    ├── aur/            # paru + paquetes AUR
    ├── dotfiles/       # chezmoi apply
    └── pentest/        # repo BlackArch + grupos
```

Por ahora el camino soportado para migrar es `install.sh` (ver README raíz).
