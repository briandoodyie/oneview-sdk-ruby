require 'spec_helper'

klass = OneviewSDK::API300::Thunderbird::Enclosure
RSpec.describe klass, integration: true, type: CREATE, sequence: seq(klass) do
  include_context 'integration api300 context'

  describe '#add' do
    it 'can add an enclosure' do
      item = klass.new($client_300, hostname: ENCL_HOSTNAME)
      item.add
      expect(item['uri']).not_to be_empty
    end
  end

  describe '#environmentalConfiguration' do
    it 'Gets the script' do
      item = klass.find_by($client_300, {}).first
      expect { item.environmental_configuration }.not_to raise_error
    end
  end

  describe '#utilization' do
    it 'Gets utilization data' do
      item = klass.find_by($client_300, {}).first
      expect { item.utilization }.not_to raise_error
    end
  end
end