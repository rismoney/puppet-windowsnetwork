class Puppet::Provider::Winnetwork < Puppet::Provider
  confine :operatingsystem => :windows

  def wmi_connect
    if Puppet.features.microsoft_windows?
      begin
        require 'win32ole'
      rescue LoadError => exc
        msg = "Could not load the required win32ole gem [#{exc.message}]"
        Puppet.err msg
        error = Puppet::Error.new(msg)
        error.set_backtrace exc.backtrace
        raise error
      end
    end
    objWMIService = WIN32OLE.connect("winmgmts:{impersonationLevel=impersonate}//./root/CIMV2")
  end

  def wmi_exec_drv(wmi, nicdescription)
     #switch friendlyname = devicename when going to servers
     wql_drv = "SELECT * FROM Win32_PnPSignedDriver WHERE devicename='#{nicdescription}'"
     wmi.ExecQuery(wql_drv)
  end

  def wmi_exec_adapter (wmi, deviceid)
    wql_adapter = "SELECT * FROM Win32_NetworkAdapter WHERE PNPDeviceID = '#{deviceid}'"
    wmi.ExecQuery(wql_adapter)
  end

  def wmi_exec_assoc(wmi, nicid)
    wql_assoc = "ASSOCIATORS OF {Win32_NetworkAdapter.DeviceID='#{nicid}'} WHERE AssocClass=Win32_NetworkAdapterSetting"
    wmi.ExecQuery(wql_assoc)
  end

  def enablestatic(adapter,ip_hash={})
    oMethod = adapter.Methods_("EnableStatic")
    oInParam = oMethod.InParameters.SpawnInstance_()
    oInParam.IPAddress = ip_hash[:ipaddress]
    oInParam.SubnetMask = ip_hash[:subnetmask]
    oOutParam = adapter.ExecMethod_("EnableStatic", oInParam)
  end

  def setgateways(adapter,gateways_hash={})
    oMethod = adapter.Methods_("SetGateways")
    oInParam = oMethod.InParameters.SpawnInstance_()
    oInParam.DefaultIPGateway = gateways_hash[:defaultgateway]
    oInParam.GatewayCostMetric = gateways_hash[:gwcostmetric].to_a
    oOutParam = adapter.ExecMethod_("SetGateways", oInParam)
  end

  def setdnsserversearchorder(adapter,searchorder)
    oMethod = adapter.Methods_("SetDNSServerSearchOrder")
    oInParam = oMethod.InParameters.SpawnInstance_()
    oInParam.DNSServerSearchOrder = searchorder
    oOutParam = adapter.ExecMethod_("SetDNSServerSearchOrder", oInParam)
  end

  def setdnssuffixsearchorder(adapter,suffixsearchorder)
    oMethod = adapter.Methods_("SetDNSSuffixSearchOrder")
    oInParam = oMethod.InParameters.SpawnInstance_()
    oInParam.DNSDomainSuffixSearchOrder = suffixsearchorder
    oOutParam = adapter.ExecMethod_("SetDNSSuffixSearchOrder", oInParam)
  end

  def setdnsdomain(adapter,dnshostname)
    oMethod = adapter.Methods_("SetDNSDomain")
    oInParam = oMethod.InParameters.SpawnInstance_()
    oInParam.DNSHostName = dnshostname
    oOutParam = adapter.ExecMethod_("SetDNSDomain", oInParam)
  end

  def setdyndns(adapter,dyndnsreg_hash={})
    oMethod = adapter.Methods_("SetDynamicDNSRegistration")
    oInParam = oMethod.InParameters.SpawnInstance_()
    oInParam.FullDNSRegistrationEnabled = (dyndnsreg_hash[:fulldnsregister] == :true)
    oInParam.DomainDNSRegistrationEnabled = (dyndnsreg_hash[:dnsregister] == :true)
    oOutParam = adapter.ExecMethod_("SetDynamicDNSRegistration", oInParam)
  end

  def netbios_map
    {
      :dhcp      => 0,
      :enabled   => 1,
      :disabled  => 2,
    }
  end

  def settcpipnetbios(adapter,netbios_hash={})
    oMethod = adapter.Methods_("SetTCPIPNetBIOS")
    oInParam = oMethod.InParameters.SpawnInstance_()
    netbiosflag=netbios_map[netbios_hash[:netbios].to_sym]
    oInParam.TcpipNetbiosOptions = netbiosflag
    oOutParam = adapter.ExecMethod_("SetTCPIPNetBIOS", oInParam)
  end
end