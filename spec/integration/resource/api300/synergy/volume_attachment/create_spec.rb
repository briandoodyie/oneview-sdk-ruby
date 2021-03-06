require 'spec_helper'

klass = OneviewSDK::API300::Synergy::VolumeAttachment
RSpec.describe klass, integration: true, type: CREATE, sequence: seq(klass) do
  include_context 'integration api300 context'

  describe '#create' do
    it 'should throw unavailable exception' do
      item = klass.new($client_300_synergy)
      expect { item.create }.to raise_error(OneviewSDK::MethodUnavailable)
    end
  end
end
