require 'spec_helper'

klass = OneviewSDK::StorageSystem
RSpec.describe klass, integration: true, type: DELETE, sequence: rseq(klass) do
  include_context 'integration context'

  describe '#remove' do
    it 'removes the storage system' do
      storage_system = OneviewSDK::StorageSystem.new($client, 'credentials' => {})
      storage_system['credentials']['ip_hostname'] = $secrets['storage_system1_ip']
      storage_system.retrieve!
      expect { storage_system.remove }.to_not raise_error
    end
  end
end
