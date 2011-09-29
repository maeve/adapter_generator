shared_examples_for 'a gem lib generator' do
  let(:lib_path) { File.join(gem_path, 'lib') }
  let(:top_module) { File.join(lib_path, "#{gem_name}.rb") }
  let(:version) { File.join(lib_path, gem_name, 'version.rb') }
  let(:client) { File.join(lib_path, gem_name, 'client.rb') }

  it "should create a directory for the new gem" do
    expect { subject }.to change { File.directory?(gem_path) }.from(false).to(true)
  end

  it "should create a lib directory" do
    expect { subject }.to change { File.directory?(lib_path) }.from(false).to(true)
  end

  it "should create a file for the top-level module" do
    expect { subject }.to change { File.file?(top_module) }.from(false).to(true)
  end

  it "should create a version file for the gem" do
    expect { subject }.to change { File.file?(version) }.from(false).to(true)
  end
  
  it "should create a file for the generated client" do
    expect { subject }.to change { File.file?(client) }.from(false).to(true)
  end

  describe "the generated module" do
    before { run_generator }

    subject { File.open(top_module, 'r') { |f| f.read } }

    it { should match /module #{module_name}/ }
    it { should match /require\s+['"]#{gem_name}\/client['"]/ }
    it { should match /require\s+['"]#{gem_name}\/version['"]/ } 
  end

  describe "the generated version" do
    before { run_generator }

    subject { File.open(version, 'r') { |f| f.read } }

    it { should match /VERSION\s*=\s*['"]0\.0\.1['"]/ }
  end

  describe "the generated client" do
    before { run_generator }

    subject { File.open(client, 'r') { |f| f.read } }

    context "with --soap" do
      let(:args) { [gem_name, '--soap'] }

      it { should match /module #{module_name}/ }
      it { should match /class Client/ }
      it { should match /def initialize/ }
      it { should match /def send_soap_request/ }
      it { should match /def soap_client/ }
    end

    context "without --soap" do
      it { should match /module #{module_name}/ }
      it { should match /class Client/ }
      it { should match /def initialize/ }
      it { should_not match /def send_soap_request/ }
      it { should_not match /def soap_client/ }
    end
  end
end
