require 'spec_helper'

RSpec.describe OneviewSDK::VolumeAttachment, integration: true, type: UPDATE do
  include_context 'integration context'

  describe '#update' do
    it 'should throw unavailable exception' do
      item = OneviewSDK::VolumeAttachment.new($client)
      expect { item.update }.to raise_error(OneviewSDK::MethodUnavailable)
    end
  end

  describe '::get_extra_unmanaged_volumes' do
    it 'should get the list of extra unmanaged storage volumes' do
      expect { klass.get_extra_unmanaged_volumes($client) }.to_not raise_error
    end
  end

  describe '::remove_extra_unmanaged_volume' do
    it 'should remove extra presentations from a specific server profile (Fail/Bug: occurs error on the http method of ruby)' do
      server_profile = OneviewSDK::ServerProfile.find_by($client, name: SERVER_PROFILE_NAME).first
      expect { klass.remove_extra_unmanaged_volume($client, server_profile) }.to_not raise_error
    end
  end

  describe '#get_paths' do
    it 'should get a list of volume attachment paths from the attachment' do
      item = klass.get_all($client).first
      expect { item.get_paths }.to_not raise_error
    end
  end
end
