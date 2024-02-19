# HL15 Arm64 NAS

Ansible playbook to configure my 45Homelab HL15 NAS, running on an Arm64 CPU.

TODO.

## Running the playbook

Ensure you have Ansible installed, and can SSH into the NAS using `ssh user@nas-ip-or-address` without entering a password, then run:

```
ansible-playbook main.yml
```

## Accessing Cockpit Web UI

The cockpit web UI should be accessible at: https://server-ip:9090
