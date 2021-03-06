require 'spec_helper'

klass = OneviewSDK::API300::Synergy::LogicalInterconnect
extra_klass_1 = OneviewSDK::API300::Synergy::EthernetNetwork
RSpec.describe klass, integration: true, type: UPDATE do
  include_context 'integration api300 context'

  let(:enclosure) { OneviewSDK::API300::Synergy::Enclosure.find_by($client_300_synergy, {}).first }
  let(:log_int) { klass.new($client_300_synergy, name: LOG_INT2_NAME) }
  let(:qos_fixture) { 'spec/support/fixtures/integration/logical_interconnect_qos.json' }
  let(:firmware_path) { 'spec/support/Service Pack for ProLiant' }

  describe '#retrieve!' do
    it 'retrieves the already created necessary objects' do
      expect { log_int.retrieve! }.to_not raise_error
      expect(enclosure[:uri]).to be
      expect(log_int[:type]).to eq('logical-interconnectV300')
    end
  end

  # ATTENTION: REAL HARDWARE ONLY
  # describe 'Manipulating interconnects' do
  #
  #   def interconnect_find(bay_number, enclosure)
  #     log_int.retrieve!
  #     enclosure_match = true
  #     bay_match = false
  #     log_int['interconnectMap']['interconnectMapEntries'].each do |interconnect|
  #       interconnect['location']['locationEntries'].each do |entry|OneviewSDK::API300::Synergy::API300::Synergy::
  #         enclosure_match = true if ((enclosure['uri'] == entry['value']) && (entry['type'] == 'Enclosure'))
  #         bay_match = true if ((bay_number.to_s == entry['value']) && (entry['type'] == 'Bay'))
  #       end
  #       return true if (enclosure_match && bay_match)
  #     end
  #     false
  #   end
  #
  #   it '#create the Interconnect in bay 2' do
  #     enclosure.retrieve!
  #     expect { log_int.create(2, enclosure) }.to_not raise_error
  #     expect(interconnect_find(2, enclosure)).to eq(true)
  #   end
  #
  #   # This example will fail if the interconnect is associated with the LIG
  #   it '#create, #delete and #create the Interconnect in bay 2' do
  #     enclosure.retrieve!
  #     expect { log_int.create(2, enclosure) }.to_not raise_error
  #     expect(interconnect_find(2, enclosure)).to eq(true)
  #
  #     expect { log_int.delete(2, enclosure) }.to_not raise_error
  #     expect(interconnect_find(2, enclosure)).to eq(false)
  #
  #     expect { log_int.create(2, enclosure) }.to_not raise_error
  #     expect(interconnect_find(2, enclosure)).to eq(true)
  #   end
  # end

  # 00:01:00.640
  describe 'Ethernet settings' do
    it 'will update igmpIdleTimeoutInterval and macRefreshInterval and Rollback' do
      log_int.retrieve!
      eth_set_backup = {}
      eth_set_backup['igmpIdleTimeoutInterval'] = log_int['ethernetSettings']['igmpIdleTimeoutInterval']
      eth_set_backup['macRefreshInterval'] = log_int['ethernetSettings']['macRefreshInterval']
      new_igmp = (eth_set_backup['igmpIdleTimeoutInterval'] + 237) % 501 + 1
      new_mac = (eth_set_backup['macRefreshInterval'] + 9) % 31 + 1

      log_int['ethernetSettings']['igmpIdleTimeoutInterval'] = new_igmp
      log_int['ethernetSettings']['macRefreshInterval'] = new_mac
      log_int.update_ethernet_settings

      log_int['ethernetSettings']['igmpIdleTimeoutInterval'] = 0
      log_int['ethernetSettings']['macRefreshInterval'] = 0
      log_int.retrieve!

      expect(log_int['ethernetSettings']['igmpIdleTimeoutInterval']).to eq(new_igmp)
      expect(log_int['ethernetSettings']['macRefreshInterval']).to eq(new_mac)

      log_int['ethernetSettings']['igmpIdleTimeoutInterval'] = eth_set_backup['igmpIdleTimeoutInterval']
      log_int['ethernetSettings']['macRefreshInterval'] = eth_set_backup['macRefreshInterval']
      log_int.update_ethernet_settings

      log_int['ethernetSettings']['igmpIdleTimeoutInterval'] = 0
      log_int['ethernetSettings']['macRefreshInterval'] = 0
      log_int.retrieve!

      log_int.retrieve!
      expect(log_int['ethernetSettings']['igmpIdleTimeoutInterval']).to eq(eth_set_backup['igmpIdleTimeoutInterval'])
      expect(log_int['ethernetSettings']['macRefreshInterval']).to eq(eth_set_backup['macRefreshInterval'])
    end

    it 'will use update settings to do it' do
      log_int.retrieve!
      eth_set_backup = {}
      eth_set_backup['igmpIdleTimeoutInterval'] = log_int['ethernetSettings']['igmpIdleTimeoutInterval']
      eth_set_backup['macRefreshInterval'] = log_int['ethernetSettings']['macRefreshInterval']
      new_igmp = (eth_set_backup['igmpIdleTimeoutInterval'] + 237) % 501 + 1
      new_mac = (eth_set_backup['macRefreshInterval'] + 9) % 31 + 1

      log_int['ethernetSettings']['igmpIdleTimeoutInterval'] = new_igmp
      log_int['ethernetSettings']['macRefreshInterval'] = new_mac
      options = {
        'ethernetSettings' => log_int['ethernetSettings'],
        'fcoeSettings' => {}
      }
      expect { log_int.update_settings(options) }.to_not raise_error

      log_int['ethernetSettings']['igmpIdleTimeoutInterval'] = 0
      log_int['ethernetSettings']['macRefreshInterval'] = 0
      log_int.retrieve!

      expect(log_int['ethernetSettings']['igmpIdleTimeoutInterval']).to eq(new_igmp)
      expect(log_int['ethernetSettings']['macRefreshInterval']).to eq(new_mac)

      log_int['ethernetSettings']['igmpIdleTimeoutInterval'] = eth_set_backup['igmpIdleTimeoutInterval']
      log_int['ethernetSettings']['macRefreshInterval'] = eth_set_backup['macRefreshInterval']

      options_2 = {
        'ethernetSettings' => log_int['ethernetSettings'],
        'fcoeSettings' => {}
      }

      expect { log_int.update_settings(options_2) }.to_not raise_error
      log_int['ethernetSettings']['igmpIdleTimeoutInterval'] = 0
      log_int['ethernetSettings']['macRefreshInterval'] = 0
      log_int.retrieve!

      expect(log_int['ethernetSettings']['igmpIdleTimeoutInterval']).to eq(eth_set_backup['igmpIdleTimeoutInterval'])
      expect(log_int['ethernetSettings']['macRefreshInterval']).to eq(eth_set_backup['macRefreshInterval'])
    end
  end

  describe 'QoS Aggregated Configuration' do
    it 'will be updated from a fixture' do
      log_int.retrieve!
      qos_config_bkp = log_int['qosConfiguration']
      log_int['qosConfiguration'] = klass.from_file($client_300_synergy, qos_fixture)['qosConfiguration']
      expect { log_int.update_qos_configuration }.to_not raise_error
      log_int['qosConfiguration'] = qos_config_bkp
      expect { log_int.update_qos_configuration }.to_not raise_error
    end
  end

  describe 'Telemetry Configuration' do
    it 'will be updated and then will rollback' do
      log_int.retrieve!

      sample_count_bkp = log_int['telemetryConfiguration']['sampleCount']
      sample_interval_bkp = log_int['telemetryConfiguration']['sampleInterval']
      sample_count_new = 24
      sample_interval_new = 3600

      log_int['telemetryConfiguration']['sampleCount'] = sample_count_new
      log_int['telemetryConfiguration']['sampleInterval'] = sample_interval_new
      log_int.update_telemetry_configuration

      log_int['telemetryConfiguration']['sampleCount'] = 0
      log_int['telemetryConfiguration']['sampleInterval'] = 0
      log_int.retrieve!

      expect(log_int['telemetryConfiguration']['sampleCount']).to eq(sample_count_new)
      expect(log_int['telemetryConfiguration']['sampleInterval']).to eq(sample_interval_new)

      log_int['telemetryConfiguration']['sampleCount'] = sample_count_bkp
      log_int['telemetryConfiguration']['sampleInterval'] = sample_interval_bkp
      log_int.update_telemetry_configuration

      log_int['telemetryConfiguration']['sampleCount'] = 0
      log_int['telemetryConfiguration']['sampleInterval'] = 0
      log_int.retrieve!

      expect(log_int['telemetryConfiguration']['sampleCount']).to eq(sample_count_bkp)
      expect(log_int['telemetryConfiguration']['sampleInterval']).to eq(sample_interval_bkp)
    end
  end

  describe '#find_by' do
    it 'returns all resources when the hash is empty' do
      names = klass.find_by($client_300_synergy, {}).map { |item| item[:name] }
      expect(names).to include(log_int[:name])
    end

    it 'finds networks by multiple attributes' do
      attrs = { status: 'OK' }
      lis = extra_klass_1.find_by($client_300_synergy, attrs)
      expect(lis).to_not eq(nil)
    end
  end

  describe 'Update SNMP Configuration' do
    it 'adds one configuration' do
      log_int.retrieve!

      # Adding configuration
      log_int['snmpConfiguration']['snmpAccess'].push('172.18.6.15/24')
      enet_trap = %w(PortStatus)
      fc_trap = %w(Other PortStatus)
      vcm_trap = %w(Legacy)
      trap_sev = %w(Normal Warning Critical)
      trap_options = log_int.generate_trap_options(enet_trap, fc_trap, vcm_trap, trap_sev)
      log_int.add_snmp_trap_destination('172.18.6.16', 'SNMPv2', 'public', trap_options)

      # Updating snmpConfiguration
      log_int.update_snmp_configuration
      entry = log_int['snmpConfiguration']['trapDestinations'].first
      expect((enet_trap.map { |x| entry['enetTrapCategories'].include?(x) }).include?(false)).to_not be
      expect((fc_trap.map { |x| entry['fcTrapCategories'].include?(x) }).include?(false)).to_not be
      expect((vcm_trap.map { |x| entry['vcmTrapCategories'].include?(x) }).include?(false)).to_not be
      expect((trap_sev.map { |x| entry['trapSeverities'].include?(x) }).include?(false)).to_not be
      expect(entry['trapDestination']).to eq('172.18.6.16')
      expect(entry['trapFormat']).to eq('SNMPv2')
      expect(entry['communityString']).to eq('public')

      log_int['snmpConfiguration']['snmpAccess'] = []
      log_int['snmpConfiguration']['trapDestinations'] = []
      log_int.update_snmp_configuration
      expect(log_int['snmpConfiguration']['snmpAccess']).to be_empty
      expect(log_int['snmpConfiguration']['trapDestinations']).to be_empty
    end
  end

  describe '#port_monitor' do
    it 'gets a collection of uplink ports eligibles for assignment to an analyzer port' do
      log_int.retrieve!
      ports = []
      expect { ports = log_int.get_unassigned_uplink_ports_for_port_monitor }.to_not raise_error
      expect(ports).to_not be_empty
    end

    it 'updates the port monitor' do
      log_int.retrieve!
      port_monitor_bkp = log_int['portMonitor']
      interconnect = OneviewSDK::API300::Synergy::Interconnect.find_by($client_300_synergy, uri: log_int['interconnects'].first).first
      downlinks = interconnect['ports'].select { |k| k['portType'] == 'Downlink' }
      port = log_int.get_unassigned_uplink_ports_for_port_monitor.select { |k| k['interconnectName'] == downlinks.first['interconnectName'] }
      options = {
        'analyzerPort' => {
          'portUri' => port.first['uri'],
          'portMonitorConfigInfo' => 'AnalyzerPort'
        },
        'enablePortMonitor' => true,
        'type' => 'port-monitor',
        'monitoredPorts' => [
          {
            'portUri' => downlinks.first['uri'],
            'portMonitorConfigInfo' => 'MonitoredToServer'
          }
        ]
      }

      log_int['portMonitor'] = options
      expect { log_int.update_port_monitor }.to_not raise_error
      log_int['portMonitor'] = port_monitor_bkp
      expect { log_int.update_port_monitor }.to_not raise_error
    end
  end

  describe '#configuration' do
    it 'reapplies configuration to all managed interconnects' do
      log_int.retrieve!
      expect { log_int.configuration }.to_not raise_error
    end
  end

  describe '#get_firmware' do
    it 'will retrieve the firmware options' do
      log_int.retrieve!
      expect { log_int.configuration }.to_not raise_error
      firmware_opt = log_int.get_firmware
      expect(firmware_opt).to be
      expect(firmware_opt['ethernetActivationDelay']).to be
      expect(firmware_opt['ethernetActivationType']).to be
      expect(firmware_opt['fcActivationDelay']).to be
      expect(firmware_opt['fcActivationType']).to be
    end
  end

  # NOTE: This action requires a firmware image to be specified
  # describe 'Firmware Updates' do
  #   it 'will assure the firmware is present' do
  #     firmware_name = firmware_path.split('/').last
  #     firmware = OneviewSDK::API300::Synergy::FirmwareDriver.new($client_300_synergy, name: firmware_name)
  #     firmware.retrieve!
  #   end
  #
  #   context 'perform the actions' do
  #     it 'Stage' do
  #       log_int.retrieve!
  #       firmware_name = firmware_path.split('/').last
  #       firmware = OneviewSDK::API300::Synergy::FirmwareDriver.new($client_300_synergy, name: firmware_name)
  #       firmware.retrieve!
  #       firmware_opt = log_int.get_firmware
  #       firmware_opt['ethernetActivationDelay'] = 7
  #       firmware_opt['ethernetActivationType'] = 'OddEven'
  #       firmware_opt['fcActivationDelay'] = 7
  #       firmware_opt['fcActivationType'] = 'Serial'
  #       firmware_opt['force'] = true
  #       expect { log_int.firmware_update('Stage', firmware, firmware_opt) }.to_not raise_error
  #     end
  #
  #   end
  # end
end
