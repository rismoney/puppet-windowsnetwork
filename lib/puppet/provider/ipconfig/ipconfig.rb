require File.join(File.dirname(__FILE__), '..', 'winnetwork')

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
      #p netconnectionid.properties_.each {|x| p x.name}
      netconnectionid.ipaddress.each { |ip|
        ipv4addrs << ip if IPAddr.new(ip).ipv4?
      }
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
      netconnectionid.ipsubnet.each { |sm|
        smasks << sm if IPAddr.new(sm).ipv4?
      }
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

  def dnshostname
    dnssuffixes ||= Array.new
    enum_netconn do |netconnectionid|
      return netconnectionid.DNSHostName
    end
  end

  def dnshostname=newvalue
    enum_netconn do |netconnectionid|
      setdnsdomain(netconnectionid,@resource[:dnshostname])
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
      netbios=netconnectionid.tcpipnetbiosoptions
      return netbios_map.invert[netbios].to_s
    end
  end

  def netbios=newvalue
    enum_netconn do |netconnectionid|
      settcpipnetbios(netconnectionid,
        :netbios     => @resource[:netbios])
    end
  end


  def create
    self.ipaddress= @resource[:ipaddress]
    self.defaultgateway = @resource[:defaultgateway]
    self.dns = @resource[:dns]
    self.dnsregister = @resource[:dnsregister]
    self.netbios = @resource[:netbios]
    self.dnsdomainsuffixsearchorder = @resource[:dnsdomainsuffixsearchorder]
    self.dnshostname = @resource[:dnshostname]
    true
  end

  def destroy
    enum_netconn do |netconnectionid|
      netconnectionid.enabledhcp()
    end
  end
end
