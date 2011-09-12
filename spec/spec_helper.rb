require 'rspec'

require 'fakefs/spec_helpers'
require 'webmock/rspec'

RSpec.configure do |config|
  config.include WebMock::API
  config.include FakeFS::SpecHelpers
end

require 'adapter_generator'
