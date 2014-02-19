require File.join(File.dirname(__FILE__), '..', 'winnetwork')
WOW64_64 = 0x100 unless defined?(WOW64_64)
WOW64_32 = 0x200 unless defined?(WOW64_32)

Puppet::Type.type(:ipconfig).provide(:ipconfig, :parent => Puppet::Provider::Winnetwork) do

  desc "Ipconfig"

  def enum_netconn
    raise "needs a block" unless block_given?

    my_wmi=self.wmi_connect
    #nicdriver=wmi_exec_drv(my_wmi,@resource[:name])

    #nicdriver.each do |device|
    #  @deviceid=device.DeviceID
    #  break
    #end

    #deviceid_esc=@deviceid.gsub('\\','\\\\\\') # wonky escaping needed.
    #adapters=wmi_exec_adapter(my_wmi, deviceid_esc)

    # this needs to be DRYed up to just wmi_exec_assoc
    # disabled deviceid based namevar and moved to human friendly
    # netconnectionid

    adapters = wmi_exec_adapter(my_wmi, @resource[:name])
    adapters.each { |adapter|

      if adapter.deviceid
        nicid=adapter.deviceid
        netconnectionids=wmi_exec_assoc(my_wmi, nicid)
        netconnectionids.each { |netconnectionid| yield netconnectionid }
      end
    }
  end




def getreg(guid,keyname) 
  require 'win32/registry'
  keypath = "SYSTEM\\CurrentControlSet\\services\\Tcpip\\Parameters\\Interfaces\\" + guid
  reg_type = Win32::Registry::KEY_READ | WOW64_64
  Win32::Registry::HKEY_LOCAL_MACHINE.open(keypath, reg_type) do |reg|
    regkey = reg[keyname]
    return regkey
  end
end
  
  
  def exists?
    rc=false
    enum_netconn do |netconnectionid|
     rc=true if netconnectionid.dhcpenabled == false
    end

    return rc
  end

  def ipaddress
    ipv4addrs ||= Array.new
    enum_netconn do |netconnectionid|
       guid=netconnectionid.settingid
       # we switched to regkey here because wmi returns
       # all ip addresses including cluster VIPs.
       # The regkey contains only the static assignments
       ipv4addrs = getreg(guid,'IPAddress')
    end
    return ipv4addrs
  end

  def ipaddress= newvalue
    enum_netconn do |netconnectionid|
    enablestatic(netconnectionid,
        :ipaddress     => @resource[:ipaddress],
        :subnetmask    => @resource[:subnetmask])
    end
  end

  def subnetmask
    smasks ||= Array.new
    enum_netconn do |netconnectionid|
      guid=netconnectionid.settingid
      # we switched to regkey here because wmi returns
      # all ip addresses including cluster VIPs.
      # The regkey contains only the static assignments
      smasks = getreg(guid,'SubnetMask')
    end
    return smasks
  end

  def subnetmask= newvalue
    ipaddress= @resource[:ipaddress]
  end

  def defaultgateway
    gws ||= Array.new
    enum_netconn do |netconnectionid|
      netconnectionid.defaultipgateway.each { |gw|
        gws << gw if IPAddr.new(gw).ipv4?
      }
    end
    return gws
  end

  def defaultgateway= newvalue
    enum_netconn do |netconnectionid|
      setgateways(netconnectionid,
        :defaultgateway    => @resource[:defaultgateway],
        :gwcostmetric      => @resource[:gwcostmetric])
    end
  end

  def gwcostmetric
    enum_netconn do |netconnectionid|
      gwcm=netconnectionid.gatewaycostmetric.to_s
      return gwcm
    end
  end

  def gwcostmetric= newvalue
    self.defaultgateway= @resource[:defaultgateway]
  end

  def dns
    dnssvrs ||= Array.new
    enum_netconn do |netconnectionid|
      return netconnectionid.dnsserversearchorder
    end

  end

  def dns=newvalue
    enum_netconn do |netconnectionid|
      setdnsserversearchorder(netconnectionid,@resource[:dns])
    end
  end

  def dnsdomainsuffixsearchorder
    dnssuffixes ||= Array.new
    enum_netconn do |netconnectionid|
      return netconnectionid.dnsdomainsuffixsearchorder
    end
  end

  def dnsdomainsuffixsearchorder=newvalue
    enum_netconn do |netconnectionid|
      setdnssuffixsearchorder(netconnectionid,@resource[:dnsdomainsuffixsearchorder])
    end
  end

  def dnsdomain
    dnssuffixes ||= Array.new
    enum_netconn do |netconnectionid|
      return netconnectionid.DNSDomain
    end
  end

  def dnsdomain=newvalue
    enum_netconn do |netconnectionid|
      setdnsdomain(netconnectionid,@resource[:dnsdomain])
    end
  end

  def dnsregister
    enum_netconn do |netconnectionid|
      dnsreg=netconnectionid.domaindnsregistrationenabled
      return dnsreg.to_s
    end
  end

  def dnsregister=newvaluencp
    enum_netconn do |netconnectionid|
      setdyndns(netconnectionid,
        :fulldnsregister => @resource[:fulldnsregister],
        :dnsregister     => @resource[:dnsregister])
    end
  end

  def fulldnsregister
    enum_netconn do |netconnectionid|
      dnsreg=netconnectionid.fulldnsregistrationenabled
      return dnsreg.to_s
    end
  end

  def fulldnsregister=newvalue
    self.dnsregister = @resource[:dnsregister]
  end

  def netbios
    enum_netconn do |netconnectionid|
      netbios=netconnectionid.tcpipnetbiosoptions.to_i
      nbsetting=Hash[netbios_map.map{ |k, v| [v, k.to_s] }][netbios]
      return nbsetting
    end
  end

  def netbios=newvalue
    enum_netconn do |netconnectionid|
      settcpipnetbios(netconnectionid,
        :netbios     => @resource[:netbios])
    end
  end


  def create
    self.dnsdomain = @resource[:dnsdomain] unless @resource[:dnsdomain].to_s.empty?
    self.ipaddress= @resource[:ipaddress]
    self.defaultgateway = @resource[:defaultgateway] unless @resource[:defaultgateway].to_s.empty?
    self.dns = @resource[:dns] unless @resource[:dns].to_s.empty?
    self.dnsregister = @resource[:dnsregister] unless @resource[:dnsregister].to_s.empty?
    self.netbios = @resource[:netbios] unless @resource[:netbios].to_s.empty?
    self.dnsdomainsuffixsearchorder = @resource[:dnsdomainsuffixsearchorder] unless @resource[:dnsdomainsuffixsearchorder].to_s.empty?
    sleep 5
    true
  end

  def destroy
    enum_netconn do |netconnectionid|
      netconnectionid.enabledhcp()
    end
  end
end
