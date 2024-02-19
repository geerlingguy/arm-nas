# HL15 Arm64 NAS

Ansible playbook to configure my 45Homelab HL15 NAS, running on an Arm64 CPU.

This playbook assumes you're running Ubuntu 20.04 Server LTS.

## Running the playbook

Ensure you have Ansible installed, and can SSH into the NAS using `ssh user@nas-ip-or-address` without entering a password, then run:

```
ansible-playbook main.yml
```
