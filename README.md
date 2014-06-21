puppet-windowsnetwork
=====================

** Member of the rismoney suite of Windows Puppet Providers **

puppet provider for windows networking
It uses wmi via win32ole

Example:

```
ipconfig {'Local Area Connection':
      ensure                      => present,
      ipaddress                   => ["10.10.10.100"],
      subnetmask                  => ["255.255.255.0"],
      defaultgateway              => ["10.10.10.1"],
      gwcostmetric                => 256,
      ipconnectionmetric          => 1,
      dnsregister                 => true,
      fulldnsregister             => true,
      netbios                     => 'enabled',
      dns                         => ['8.8.8.8','8.8.4.4'],
      dnsdomainsuffixsearchorder  => ['example.com','example2.com'],
      dnsdomain                   => 'example.com'
```
