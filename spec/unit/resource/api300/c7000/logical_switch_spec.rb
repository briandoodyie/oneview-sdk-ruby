require 'spec_helper'

RSpec.describe OneviewSDK::API300::C7000::LogicalSwitch do
  include_context 'shared context'

  it 'inherits from API200' do
    expect(described_class).to be < OneviewSDK::API200::LogicalSwitch
  end

  describe '#initialize' do
    context 'OneView 2.0' do
      it 'sets the defaults correctly' do
        logical_switch = OneviewSDK::API300::C7000::LogicalSwitch.new(@client_300)
        expect(logical_switch[:type]).to eq('logical-switchV300')
      end
    end
  end

  describe '#get_internal_link_sets' do
    it 'finds the specified internal link set' do
      internal_link_set_list = FakeResponse.new(
        'members' => [
          { 'name' => 'InternalLinkSet1', 'uri' => 'rest/fake/internal-link-set' },
          { 'name' => 'InternalLinkSet2', 'uri' => 'rest/fake/B' },
          { 'name' => 'InternalLinkSet3', 'uri' => 'rest/fake/C' }
        ]
      )
      expect(@client_300).to receive(:rest_get).with('/rest/internal-link-sets').and_return(internal_link_set_list)
      item = OneviewSDK::API300::C7000::LogicalSwitch.get_internal_link_set(@client_300, 'InternalLinkSet1')
      expect(item['uri']).to eq('rest/fake/internal-link-set')
    end
  end

  describe 'Validate structs' do
    it 'SSH credentials' do
      ssh_credentials = OneviewSDK::API300::C7000::LogicalSwitch::CredentialsSSH.new('ssh_user', 'ssh_password')
      expect(ssh_credentials.user).to eq('ssh_user')
      expect(ssh_credentials.password).to eq('ssh_password')
    end

    it 'SNMPv1 Credentials' do
      snmp_v1 = OneviewSDK::API300::C7000::LogicalSwitch::CredentialsSNMPV1.new(161, 'public')
      expect(snmp_v1.port).to eq(161)
      expect(snmp_v1.community_string).to eq('public')
      expect(snmp_v1.version).to eq('SNMPv1')
    end

    it 'SNMPv3 Credentials' do
      snmp_v3 = OneviewSDK::API300::C7000::LogicalSwitch::CredentialsSNMPV3.new(161, 'user',
                                                                                'MD5',
                                                                                'auth_password',
                                                                                'AES128',
                                                                                'privacy_password')
      expect(snmp_v3.port).to eq(161)
      expect(snmp_v3.user).to eq('user')
      expect(snmp_v3.auth_protocol).to eq('MD5')
      expect(snmp_v3.auth_password).to eq('auth_password')
      expect(snmp_v3.privacy_protocol).to eq('AES128')
      expect(snmp_v3.privacy_password).to eq('privacy_password')
      expect(snmp_v3.version).to eq('SNMPv3')
    end
  end

  describe '#refresh_state' do
    it 'Refresh logical switch' do
      item = OneviewSDK::API300::C7000::LogicalSwitch.new(@client_300, uri: '/rest/fake')
      expect(@client_300).to receive(:rest_put).with("#{item['uri']}/refresh").and_return(FakeResponse.new({}))
      item.refresh_state
    end
  end

  describe '#set_logical_switch_group' do
    it 'Valid logical switch group' do
      logical_switch_group = { 'uri' => '/rest/fake/logical-switch-groups' }
      item = OneviewSDK::API300::C7000::LogicalSwitch.new(@client_300)
      item.set_logical_switch_group(logical_switch_group)
      expect(item['logicalSwitchGroupUri']).to eq('/rest/fake/logical-switch-groups')
    end
  end

  describe '#set_switch_credentials' do
    it 'Valid structure and host for SNMPv1' do
      item = OneviewSDK::API300::C7000::LogicalSwitch.new(@client_300)
      ssh_credentials = OneviewSDK::API300::C7000::LogicalSwitch::CredentialsSSH.new('ssh_user', 'ssh_password')
      snmp_v1 = OneviewSDK::API300::C7000::LogicalSwitch::CredentialsSNMPV1.new(161, 'public')
      item.set_switch_credentials('127.0.0.1', ssh_credentials, snmp_v1)
      expect(item.logical_switch_credentials['127.0.0.1'][0]).to eq(ssh_credentials)
      expect(item.logical_switch_credentials['127.0.0.1'][1]).to eq(snmp_v1)
    end

    it 'Valid structure and host for SNMPv3' do
      item = OneviewSDK::API300::C7000::LogicalSwitch.new(@client_300)
      ssh_credentials = OneviewSDK::API300::C7000::LogicalSwitch::CredentialsSSH.new('ssh_user', 'ssh_password')
      snmp_v3 = OneviewSDK::API300::C7000::LogicalSwitch::CredentialsSNMPV3.new(161, 'public',
                                                                                'MD5',
                                                                                'auth_password',
                                                                                'AES128',
                                                                                'privacy_password')
      item.set_switch_credentials('127.0.0.1', ssh_credentials, snmp_v3)
      expect(item.logical_switch_credentials['127.0.0.1'][0]).to eq(ssh_credentials)
      expect(item.logical_switch_credentials['127.0.0.1'][1]).to eq(snmp_v3)
    end

    it 'Invalid SSH crendential parameter' do
      item = OneviewSDK::API300::C7000::LogicalSwitch.new(@client_300)
      SSHFake_C7000 = Struct.new(:user, :password)
      ssh_credentials = SSHFake_C7000.new('ssh_user', 'ssh_password')
      snmp_v1 = OneviewSDK::API300::C7000::LogicalSwitch::CredentialsSNMPV1.new(161, 'public')
      expect { item.set_switch_credentials('127.0.0.1', ssh_credentials, snmp_v1) }.to raise_error(
        TypeError, /Use struct<OneviewSDK::LogicalSwitch::CredentialsSSH>/
      )
    end

    it 'Invalid SNMP credential parameter' do
      item = OneviewSDK::API300::C7000::LogicalSwitch.new(@client_300)
      ssh_credentials = OneviewSDK::API300::C7000::LogicalSwitch::CredentialsSSH.new('ssh_user', 'ssh_password')
      SNMPFake_C7000 = Struct.new(:port, :community_string, :version) do
        def version
          'SNMP'
        end
      end
      snmp_v1 = SNMPFake_C7000.new(161, 'public')
      expect { item.set_switch_credentials('127.0.0.1', ssh_credentials, snmp_v1) }.to raise_error(
        TypeError, /Use struct<OneviewSDK::LogicalSwitch::CredentialsSNMP>/
      )
    end
  end

  describe '#create' do
    it 'Basic structure' do
      logical_switch = OneviewSDK::API300::C7000::LogicalSwitch.new(@client_300)
      expect(@client_300).to receive(:rest_post).with(
        '/rest/logical-switches',
        {
          'body' => {
            'logicalSwitch' => {
              'type' => 'logical-switchV300',
              'switchCredentialConfiguration' => []
            },
            'logicalSwitchCredentials' => []
          }
        },
        300
      ).and_return(FakeResponse.new({}))
      logical_switch.create
    end

    it 'Adding SNMPv1 switch' do
      logical_switch = OneviewSDK::API300::C7000::LogicalSwitch.new(@client_300)
      ssh_credentials = OneviewSDK::API300::C7000::LogicalSwitch::CredentialsSSH.new('ssh_user', 'ssh_password')
      snmp_v1 = OneviewSDK::API300::C7000::LogicalSwitch::CredentialsSNMPV1.new(161, 'public')
      logical_switch.set_switch_credentials('127.0.0.1', ssh_credentials, snmp_v1)
      expect(@client_300).to receive(:rest_post).with(
        '/rest/logical-switches',
        {
          'body' => {
            'logicalSwitch' => {
              'type' => 'logical-switchV300',
              'switchCredentialConfiguration' => [
                {
                  'snmpPort' => 161,
                  'snmpV3Configuration' => nil,
                  'snmpV1Configuration' => {
                    'communityString' => 'public'
                  },
                  'logicalSwitchManagementHost' => '127.0.0.1',
                  'snmpVersion' => 'SNMPv1'
                }
              ]
            },
            'logicalSwitchCredentials' => [
              {
                'connectionProperties' => [
                  {
                    'valueFormat' => 'Unknown',
                    'propertyName' => 'SshBasicAuthCredentialUser',
                    'valueType' => 'String',
                    'value' => 'ssh_user'
                  },
                  {
                    'valueFormat' => 'SecuritySensitive',
                    'propertyName' => 'SshBasicAuthCredentialPassword',
                    'valueType' => 'String',
                    'value' => 'ssh_password'
                  }
                ]
              }
            ]
          }
        },
        300
      ).and_return(FakeResponse.new({}))
      logical_switch.create
    end

    it 'Adding SNMPv3 switch' do
      logical_switch = OneviewSDK::API300::C7000::LogicalSwitch.new(@client_300)
      ssh_credentials = OneviewSDK::API300::C7000::LogicalSwitch::CredentialsSSH.new('ssh_user', 'ssh_password')
      snmp_v3 = OneviewSDK::API300::C7000::LogicalSwitch::CredentialsSNMPV3.new(161, 'user',
                                                                                'MD5',
                                                                                'auth_password',
                                                                                'AES128',
                                                                                'privacy_password')
      logical_switch.set_switch_credentials('127.0.0.1', ssh_credentials, snmp_v3)
      expect(@client_300).to receive(:rest_post).with(
        '/rest/logical-switches',
        {
          'body' => {
            'logicalSwitch' => {
              'type' => 'logical-switchV300',
              'switchCredentialConfiguration' => [
                {
                  'snmpPort' => 161,
                  'snmpV3Configuration' => {
                    'securityLevel' => 'AuthPrivacy',
                    'privacyProtocol' => 'AES128',
                    'authorizationProtocol' => 'MD5'
                  },
                  'snmpV1Configuration' => nil,
                  'logicalSwitchManagementHost' => '127.0.0.1',
                  'snmpVersion' => 'SNMPv3'
                }
              ]
            },
            'logicalSwitchCredentials' => [
              {
                'connectionProperties' => [
                  {
                    'valueFormat' => 'Unknown',
                    'propertyName' => 'SshBasicAuthCredentialUser',
                    'valueType' => 'String',
                    'value' => 'ssh_user'
                  },
                  {
                    'valueFormat' => 'SecuritySensitive',
                    'propertyName' => 'SshBasicAuthCredentialPassword',
                    'valueType' => 'String',
                    'value' => 'ssh_password'
                  },
                  {
                    'valueFormat' => 'SecuritySensitive',
                    'propertyName' => 'SnmpV3AuthorizationPassword',
                    'valueType' => 'String',
                    'value' => 'auth_password'
                  },
                  {
                    'valueFormat' => 'Unknown',
                    'propertyName' => 'SnmpV3User',
                    'valueType' => 'String',
                    'value' => 'user'
                  },
                  {
                    'valueFormat' => 'SecuritySensitive',
                    'propertyName' => 'SnmpV3PrivacyPassword',
                    'valueType' => 'String',
                    'value' => 'privacy_password'
                  }
                ]
              }
            ]
          }
        },
        300
      ).and_return(FakeResponse.new({}))
      logical_switch.create
    end
  end
end
