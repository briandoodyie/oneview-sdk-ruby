require 'spec_helper'

klass = OneviewSDK::ImageStreamer::API300::BuildPlan
RSpec.describe klass do
  include_context 'shared context'

  describe '#initialize' do
    it 'sets the defaults correctly' do
      item = klass.new(@client_i3s_300)
      expect(item['type']).to eq('OeBuildPlan')
    end
  end

  describe '#set_build_step' do
    it 'creates a build plan with build step' do
      options = [
        {
          serialNumber: '1',
          parameters: 'anystring',
          planScriptName: 'planScript1',
          planScriptUri: 'rest/plan-scrips/fake'
        }
      ]
      item = klass.new(@client_i3s_300)
      item.set_build_step(options)
      expect(item['buildStep']).to_not be_empty
      expect(item['buildStep'].first[:serialNumber]).to eq('1')
      expect(item['buildStep'].first[:parameters]).to eq('anystring')
      expect(item['buildStep'].first[:planScriptName]).to eq('planScript1')
      expect(item['buildStep'].first[:planScriptUri]).to eq('rest/plan-scrips/fake')
    end
  end
end