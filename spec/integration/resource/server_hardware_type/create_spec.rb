require 'spec_helper'

klass = OneviewSDK::ServerHardwareType
RSpec.describe klass, integration: true, type: CREATE, sequence: seq(klass) do
  include_context 'integration context'

  describe 'Create server hardware type adding by adding a server hardware' do
    it 'can create resources' do
      options = {
        hostname: $secrets['server_hardware2_ip'],
        username: $secrets['server_hardware2_username'],
        password: $secrets['server_hardware2_password'],
        name: 'teste',
        licensingIntent: 'OneView'
      }

      item = OneviewSDK::ServerHardware.new($client, options)
      expect { item.create }.to_not raise_error
    end
  end
end