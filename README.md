puppet-windowsnetwork
=====================

** Member of the rismoney suite of Windows Puppet Providers **

puppet provider for windows networking
It uses wmi via win32ole

Example:

```
ipconfig {'Intel(R) 82567LM-3 Gigabit Network Connection':
      ensure            => present,
      ipaddress         => ["10.10.10.100"],
      subnetmask        => ["255.255.255.0"],
      defaultgw         => ["10.10.10.1"],
      gwcostmetric      =>  256,
      dnsregister       => false,
      fulldnsregister   => false,
      netbios           => 'dhcp',
      dns               => ["8.8.8.8","8.8.4.4"],
}
```
