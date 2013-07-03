ipconfig {'Local Area Connection':
      ensure                      => present,
      ipaddress                   => ["10.10.10.100"],
      subnetmask                  => ["255.255.255.0"],
      defaultgateway              => ["10.10.10.1"],
      gwcostmetric                =>  256,
      dnsregister                 => true,
      fulldnsregister             => true,
      netbios                     => 'enabled',
      dns                         => ['8.8.8.8','8.8.4.4'],
      dnsdomainsuffixsearchorder  => ['example.com','example2.com'],
      dnsdomain                   => 'example.com'
}