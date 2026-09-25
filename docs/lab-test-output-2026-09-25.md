# Sanitized Lab Test Output — 2026-09-25

This file captures representative console output from repository qualification in the lab. It is intentionally sanitized for public viewing.

## Sanitization

The original lab used RFC1918 addresses and local account names. Those values have been replaced here with documentation address space and generic identities:

- Repository server: `192.0.2.10`
- Management workstation: `192.0.2.20`
- Test network device: `192.0.2.30`
- Device user: `lab-user`

No customer names, production addresses, credentials, vendor binaries, or private keys are included.

## Nginx configuration validation

```text
root@network-os-repo-poc:~# nginx -t
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
```

## Local HTTP transfer logging

A local GET of the staged test object produced both activity and transfer-success records:

```text
2026-09-25T11:59:54-04:00 REQUEST ip=127.0.0.1 method=GET uri="/vendor/os/platform/test-object.yml" status=200 bytes=18708 duration=0.000 connection=6
2026-09-25T11:59:54-04:00 TRANSFER_OK ip=127.0.0.1 file="/vendor/os/platform/test-object.yml" status=200 bytes=18708 duration=0.000 connection=6
```

## Remote workstation transfer logging

A management workstation retrieved the same object successfully:

```text
2026-09-25T12:02:23-04:00 TRANSFER_OK ip=192.0.2.20 file="/vendor/os/platform/test-object.yml" status=200 bytes=18708 duration=0.000 connection=7
```

This validated remote HTTP retrieval plus the simplified operational logging format.

## Network-device reachability

A Juniper EX2200 running Junos 12.3R12-S21 was used as a real network-device HTTP client.

```text
lab-user@EX2200-LAB-01> ping 192.0.2.10 count 5
PING 192.0.2.10 (192.0.2.10): 56 data bytes
64 bytes from 192.0.2.10: icmp_seq=0 ttl=64 time=14.066 ms
64 bytes from 192.0.2.10: icmp_seq=1 ttl=64 time=3.670 ms
64 bytes from 192.0.2.10: icmp_seq=2 ttl=64 time=3.701 ms
64 bytes from 192.0.2.10: icmp_seq=3 ttl=64 time=3.290 ms
64 bytes from 192.0.2.10: icmp_seq=4 ttl=64 time=2.928 ms
```

## Network-device storage check

The switch had ample free space in `/var/tmp` before the transfer:

```text
Filesystem              Size       Used      Avail  Capacity   Mounted on
/dev/da0s3d             369M       276K       339M        0%  /var/tmp
```

## Network-device HTTP retrieval

The EX2200 retrieved the repository object directly over HTTP into `/var/tmp`:

```text
lab-user@EX2200-LAB-01> file copy http://192.0.2.10/vendor/os/platform/test-object.yml /var/tmp/repo-transfer-test.yml
/var/home/lab-user/...transferring.file.........100% of   18 kB  908 kBps
```

The destination file existed at the expected size:

```text
lab-user@EX2200-LAB-01> file list /var/tmp/repo-transfer-test.yml detail
-rw-r--r--  1 lab-user field     18708 Sep 25 16:06 /var/tmp/repo-transfer-test.yml
total files: 1
```

## Device-side integrity verification

```text
lab-user@EX2200-LAB-01> file checksum sha-256 /var/tmp/repo-transfer-test.yml
SHA256 (/var/tmp/repo-transfer-test.yml) = b1644006948f2ddab3fd6e853bef269611b57bebcfbf9e6f3b5d275964103aac
```

## Repository-side transfer record

The Nginx transfer-success log recorded the EX2200 as the HTTP client and recorded the expected byte count:

```text
2026-09-25T12:06:50-04:00 TRANSFER_OK ip=192.0.2.30 file="/vendor/os/platform/test-object.yml" status=200 bytes=18708 duration=0.000 connection=9
```

## Repository-side integrity verification

```text
root@network-os-repo-poc:~# sha256sum /srv/network-os/vendor/os/platform/test-object.yml
b1644006948f2ddab3fd6e853bef269611b57bebcfbf9e6f3b5d275964103aac  /srv/network-os/vendor/os/platform/test-object.yml
```

The device-side and repository-side SHA-256 values matched exactly.

## Result

The test demonstrated the complete generic transfer chain:

```text
network device
    -> HTTP GET
repository server
    -> successful response logged
network device local storage
    -> expected byte count
    -> matching SHA-256
```

**Result: PASS**

This validates generic device-side HTTP retrieval, repository logging, and transfer integrity. It does not replace vendor-specific software-download, validation, or activation testing on the actual target platform.
