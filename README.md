# HL15 Arm64 NAS

Ansible playbook to configure my 45Homelab HL15 NAS, running on an Arm64 CPU.

This playbook assumes you're running Ubuntu 20.04 Server LTS.

## Running the playbook

Ensure you have Ansible installed, and can SSH into the NAS using `ssh user@nas-ip-or-address` without entering a password, then run:

```
ansible-playbook main.yml
```

## Benchmarks

There's a disk benchmarking script included, which allows me to test various performance scenarios on the server.

You can run it by copying it to the server, making it executable, and running it with `sudo`:

```
chmod +x disk-benchmark.sh
sudo ./disk-benchmark.sh
```

## License

GPLv3 or later

## Author

Jeff Geerling
