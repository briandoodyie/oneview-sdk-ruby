module OneviewSDK
  # Resource for enclosure groups
  # Common Data Attributes:
  #   associatedLogicalInterconnectGroups
  #   category
  #   created
  #   description
  #   eTag
  #   enclosureCount
  #   enclosureTypeUri
  #   interconnectBayMappingCount (Required)
  #   interconnectBayMappings (Required)
  #   ipAddressingMode
  #   ipRangeUris (not used in C7000 enclosure)
  #   modified
  #   name
  #   portMappingCount
  #   portMappings
  #   powerMode
  #   stackingMode (Required)
  #   state
  #   status
  #   type (Required)
  #   uri
  class EnclosureGroup < Resource
    BASE_URI = '/rest/enclosure-groups'

    def initialize(client, params = {}, api_ver = nil)
      super
      # Default values:
      case @api_version
      when 120
        @data['type'] ||= 'EnclosureGroupV2'
      when 200
        @data['type'] ||= 'EnclosureGroupV200'
      end
    end

    def validate_interconnectBayMappingCount(value)
      fail 'Interconnect Bay Mapping Count out of range 1..8' unless value.between?(1, 8)
    end

    def validate_ipAddressingMode(value)
      fail 'Invalid ip AddressingMode' unless %w(DHCP External IpPool).include?(value)
    end

    def validate_portMappingCount(value)
      fail 'Port Mapping Count out of range 0..8' unless value.between?(0, 8)
    end

    def validate_powerMode(value)
      fail 'Invalid powerMode' unless %w(RedundantPowerFeed RedundantPowerSupply).include?(value) || value.nil?
    end

    def validate_stackingMode(value)
      fail 'Invalid network type' unless %w(Enclosure MultiEnclosure None SwitchPairs).include?(value)
    end

  end
end