Puppet::Type.newtype(:ipconfig) do
  @doc = "Manage network configuration information"

  ensurable

  def valid_v4?(addr)
    if /^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.0$/ =~ addr
      return $~.captures.all? {|i| i = i.to_i; i >= 0 and i <= 255 }
    end
    return false
  end

  newparam(:name) do
    isnamevar
    desc "The nicdescription of the physical or logical network device"
  end

  newproperty(:ipaddress, :array_matching => :all) do
    desc "The IP address of the network interfaces"
  end

  newproperty(:subnetmask, :array_matching => :all) do
    desc "The subnet mask to apply to the interface"
  end

  newproperty(:defaultgateway, :array_matching => :all) do
    desc "The host's IP address, IPv4"
  end

  newproperty(:gwcostmetric) do
    desc 'Gateways cost metric'
    defaultto 256
  end

  newproperty(:dnsdomainsuffixsearchorder, :array_matching => :all) do
    desc 'Append these DNS Suffixes'
  end

  newproperty(:dnshostname) do
    desc 'DNS Suffix for this connection'
  end

  newproperty(:dnsregister, :boolean => true) do
    desc 'Register this connections address in DNS'
    newvalues(:true, :false)
    defaultto :true
  end

  newproperty(:fulldnsregister, :boolean => true) do
    desc 'Use this connections DNS suffix in DNS registraton'
    newvalues(:true, :false)
    defaultto :false
  end

  newproperty(:netbios) do
    desc 'Netbios setting, Enable Netbios over TCPIP, Disable over TCPIP, or Use Netbios via DHCP'
    newvalues(:enabled, :disabled, :dhcp)
    defaultto :dhcp
  end

  newproperty(:dns, :array_matching => :all) do
    desc 'DNS Server List'
  end

end