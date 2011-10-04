shared_examples_for 'a rspec configurer' do
  let(:spec_path) { File.join(gem_path, 'spec') }
  let(:spec_helper) { File.join(spec_path, 'spec_helper.rb') }
  let(:top_spec) { File.join(spec_path, "#{gem_name}_spec.rb") }

  it 'should create the .rspec config file' do
    expect { subject }.to change { File.file?(File.join(gem_path, '.rspec')) }.from(false).to(true)
  end

  it 'should create the spec directory' do
    expect { subject }.to change { Dir.exists?(spec_path) }.from(false).to(true)
  end

  it 'should create the spec_helper.rb' do
    expect { subject }.to change { File.file?(spec_helper) }.from(false).to(true)
  end

  describe 'the spec_helper.rb' do
    before { run_generator }
    subject { File.open(spec_helper, 'r') { |f| f.read } }

    it { should match /require\s+['"]rspec['"]/ }
    it { should match /require\s+['"]fakefs\/spec_helpers['"]/ }
    it { should match /require\s+['"]webmock\/rspec['"]/ }
    it { should match /require\s+['"]#{gem_name}['"]/ }
    it { should match /RSpec\.configure\s+do\s+\|config\|/ }
    it { should match /config\.include\s+FakeFS::SpecHelpers\s+/ }
  end

  it 'should create the top-level spec' do
    expect { subject }.to change { File.file?(File.join(top_spec)) }.from(false).to(true)
  end

  describe 'the top-level spec' do
    before { run_generator }
    subject { File.open(top_spec, 'r') { |f| f.read } }

    it { should match /require\s+['"]spec_helper['"]/ }
    it { should match /describe #{module_name} do/ }
    it { should match /it ['"]should/ }
  end

  it 'should create the support directory' do
    expect { subject }.to change { Dir.exists?(File.join(spec_path, 'support')) }.from(false).to(true)
  end

  it 'should create the directory for the remaining specs' do
    expect { subject }.to change { Dir.exists?(File.join(spec_path, gem_name)) }.from(false).to(true)
  end

  let(:config_spec) { File.join(spec_path, gem_name, 'configuration_spec.rb') }

  it 'should create the configuration spec' do
    expect { subject }.to change { File.exists?(config_spec) }.from(false).to(true)
  end

  describe 'the configuration spec' do
    before { run_generator }
    subject { File.open(config_spec, 'r') { |f| f.read } }

    it { should match /require\s+['"]spec_helper['"]/ }
    it { should match /describe #{module_name}::Configuration do/ }
  end

  let(:client_spec) { File.join(spec_path, gem_name, 'client_spec.rb') }

  it 'should create the client spec' do
    expect { subject }.to change { File.exists?(client_spec) }
  end

  describe 'the client spec' do
    before { run_generator }
    subject { File.open(client_spec, 'r') { |f| f.read } }

    it { should match /require\s+['"]spec_helper['"]/ }
    it { should match /describe #{module_name}::Client/ }
  end
end
