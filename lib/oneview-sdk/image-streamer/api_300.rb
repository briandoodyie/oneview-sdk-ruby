# (c) Copyright 2016 Hewlett Packard Enterprise Development LP
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed
# under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
# CONDITIONS OF ANY KIND, either express or implied. See the License for the specific
# language governing permissions and limitations under the License.

module OneviewSDK
  # Module API 300
  module API300
    # Module Image Streamer
    module ImageStreamer
      # Get resource class that matches the type given
      # @param [String] type Name of the desired class type
      #   It exists only so that the parameters match API modules that do have multiple variants.
      # @return [Class] Resource class or nil if not found
      def self.resource_named(type)
        OneviewSDK::API300.resource_named(type, 'ImageStreamer')
      end
    end
  end
end

# Load all API-specific resources:
Dir[File.dirname(__FILE__) + '/api300/*.rb'].each { |file| require file }