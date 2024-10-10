# Arm NAS

Ansible playbook to configure my Arm NASes:

  - [HL15 with Ampere Altra](#primary-nas)
  - [Raspberry Pi 5 SATA NAS](#secondary-nas)

## Hardware

### <a name="primary-nas"></a>Primary NAS - 45Drives HL15

<p align="center"><img alt="45Homelab HL15 with Jeff Geerling hardware" src="/resources/hl15-hardware.jpeg" height="auto" width="600"></p>

The current iteration of the HL15 I'm running contains the following hardware:

  - (Motherboard) [ASRock Rack ALTRAD8UD-1L2T](https://reurl.cc/qrnXNp) ([specs](https://reurl.cc/67jk0V))
  - (Case) [45Homelab HL15 + backplane + PSU](https://store.45homelab.com/configure/hl15)
  - (PSU) [Corsair RM750e](https://amzn.to/3OyDQ79)
  - (RAM) [8x Samsung 16GB 1Rx4 ECC RDIMM M393A2K40DB3-CWE PC25600](https://amzn.to/49lCtkb)
  - (NVMe) [Kioxia XG8 2TB NVMe SSD](https://amzn.to/3Uzag5d)
  - (CPU) [Ampere Altra Q32-17](https://amperecomputing.com/briefs/ampere-altra-family-product-brief)
  - (SSDs) [4x Samsung 8TB 870 QVO 2.5" SATA](https://amzn.to/3OylbZk)
  - (HDDs) [6x Seagate EXOS 20TB SATA HDD](https://amzn.to/3OA2CDM)
  - (HBA) [Broadcom MegaRAID 9405W-16i](https://amzn.to/3srcZOh)
  - (Cooler) [Noctua NH-D9 AMP-4926 4U](https://noctua.at/en/nh-d9-amp-4926-4u)
  - (Case Fans) [6x Noctua NF-A12x25 PWM](https://amzn.to/3SUReE7)
  - (Fan Hub) [Noctua NA-FH1 8 channel Fan Hub](https://amzn.to/3SVPL01)

Some of the above links are affiliate links. I have a series of videos showing how I put this system together:

  - Part 1: [How efficient can I build the 100% Arm NAS?](https://www.youtube.com/watch?v=Hz5k5WgTkcc)
  - Part 2: [Silencing the 100% Arm NAS—while making it FASTER?](https://www.youtube.com/watch?v=iD9awxmOGG4)

### <a name="secondary-nas"></a>Secondary NAS - Raspberry Pi 5 with SATA HAT

<p align="center"><img alt="Raspberry Pi 5 with Jeff Geerling hardware" src="/resources/raspberrypi-5-hardware.jpeg" height="auto" width="600"></p>

The current iteration of the Raspberry Pi 5 SATA NAS I'm running contains the following hardware:

  - (SBC) [Raspberry Pi 5](https://www.raspberrypi.com/products/raspberry-pi-5/)
  - (HAT) [Radxa Penta SATA HAT for Pi 5](https://amzn.to/3UyWXBr)
  - (SSDs) [Samsung 870 QVO 8TB SATA SSD](https://amzn.to/3y2nrSR)
  - (microSD) [Kingston Industrial 16GB A1](https://amzn.to/3y2noGF)
  - (Network) [Plugable 2.5GB USB Ethernet Adapter](https://amzn.to/4b9QMt1)
  - (Power) [TMEZON 12V 5A AC adapter](https://amzn.to/3QhYKIw)

Some of the above links are affiliate links. I have a series of videos showing how I put this system together:

  - Part 1: [The ULTIMATE Raspberry Pi 5 NAS](https://www.youtube.com/watch?v=l30sADfDiM8)
  - Part 2: [Big NAS, Lil NAS](https://www.youtube.com/watch?v=D8EIs8s303k)

## Preparing the hardware

The HL15 should not require any special prep, besides having Ubuntu installed. The Raspberry Pi 5 is running Debian (Pi OS) and needs its PCIe connection enabled. To do that:

  1. Edit the boot config: `sudo nano /boot/firmware/config.txt`
  2. Add in the following config at the bottom and save the file:

     ```
     dtparam=pciex1
     dtparam=pciex1_gen=3
     ```
  
  3. Reboot

Confirm the SATA drives are recognized with `lsblk`.

## Running the playbook

Ensure you have Ansible installed, and can SSH into the NAS using `ssh user@nas-ip-or-address` without entering a password, then run:

```
ansible-playbook main.yml
```

## Accessing Samba Shares

After the playbook runs, you should be able to access Samba shares, for example the `hddpool/jupiter` share, by connecting to the server at the path:

```
smb://nas01.mmoffice.net/hddpool_jupiter
```

Until [issue #2](https://github.com/geerlingguy/hl15-arm64-nas/issues/2) is resolved, there is one manual step required to add a password for the `jgeerling` user (one time). Log into the server via SSH, run the following command, and enter a password when prompted:

```
sudo smbpasswd -a jgeerling
```

The same thing goes for the Pi, if you want to access it's ZFS volume.

## Replication / Backups

Backups of the primary NAS (nas01) to the secondary NAS (nas02) are handled using [Sanoid](https://github.com/jimsalterjrs/sanoid) (and it's included `syncoid` replication tool).

Sanoid is configured on nas01 to store a set of monthly, daily, and hourly snapshots. Syncoid is run on cron on nas02 to pull snapshots nightly.

Sanoid should prune snapshots on nas01, and Syncoid on nas02.

You can check on snapshot health with:

  - nas01: `sudo sanoid --monitor-snapshots && zfs list -t snapshot`
  - nas02: `zfs list -t snapshot`

For example:

```
jgeerling@nas01:~$ sudo sanoid --monitor-snapshots
OK: all monitored datasets (hddpool/jupiter) have fresh snapshots
```

### Offsite Backups to Amazon Glacier

Following the [1-2-3 Backup Principle](https://www.jeffgeerling.com/blog/2021/my-backup-plan), I have an offsite replica of all my data stored on an Amazon S3 Glacier Deep Archive-backed bucket.

This keeps offsite storage costs minimal (about $1/TB/month), and using `rclone`, it is easy enough to keep things in sync between my onsite backups and S3.

The S3 bucket is owned by IAM user `rclone`, and is named `mm-archive`.

Locally, `rclone config` is set up with an Access Key and Secret Access Key for that `rclone` IAM user, and allows NAS02 to synchronize directories straight into the Amazon S3 bucket.

Full documentation of the setup is in [this GitHub issue](https://github.com/geerlingguy/arm-nas/issues/14).

#### Office Backup Retrieval

TODO: We'll cross this bridge if we come to it. The only time I've ever had to retrieve a folder, I used rclone to sync down the directory but it was a bit of a hassle, since Deep Archive means you have to request files to be put back online for retrieval, and this can take 6-24 hours!

## Benchmarks

I like to verify the performance of my NAS storage pools on the device itself, using my [`disk-benchmark.sh` script](https://github.com/geerlingguy/pi-cluster/blob/master/benchmarks/disk-benchmark.sh).

You can run it by copying it to the server, making it executable, and running it with `sudo`:

```
wget https://raw.githubusercontent.com/geerlingguy/pi-cluster/master/benchmarks/disk-benchmark.sh
chmod +x disk-benchmark.sh
sudo MOUNT_PATH=/nvmepool/mercury TEST_SIZE=20g ./disk-benchmark.sh
```

## Troubleshooting

### Samba Monitoring

If you're having trouble mounting a share or authenticating with Samba, run `sudo watch smbstatus` to monitor connections to the server. Logs inside `/var/log/samba` aren't useful by default.

### ZFS Command Line Cheat Sheet

```
# Check pool health (should return 'all pools are healthy')
zpool status -x

# List all zfs pools and datasets
zfs list

# List all zfs pool info
zpool list

# List single zfs pool info (verbose)
zpool status -v [pool_name]

# List all properties for a pool
zfs get all [pool_name]

# Scrub a pool manually (check progress with `zpool status -v`)
zpool scrub [pool_name]

# Monitor zfs I/O statistics (update every 2s)
zpool iostat 2
```

## License

GPLv3 or later

## Author

Jeff Geerling
