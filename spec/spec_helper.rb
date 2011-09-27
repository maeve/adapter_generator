require 'rspec'

require 'fakefs/spec_helpers'
require 'fakefs/require'

require 'webmock/rspec'

Dir["#{File.expand_path('../support', __FILE__)}/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.include WebMock::API
  config.include FakeFS::SpecHelpers
  config.include AdapterGenerator::Spec::Helpers

  config.before(:each) { FakeFS::Require.activate!(:fallback => true) }
  config.after(:each) { FakeFS::Require.deactivate! }
end

require 'adapter_generator'
