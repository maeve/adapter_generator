shared_examples_for 'a configuration generator' do
  let(:config_file) { File.join(gem_path, 'lib', gem_name, 'configuration.rb') }
  let(:config) { File.open(config_file, 'r') { |f| f.read } }

  context "with --soap" do
    let(:args) { [gem_name_arg, '--soap'] }

    it 'should create a file for the configuration implementation' do
      expect { subject }.to change { File.file?(config_file) }.from(false).to(true)
    end

    describe "the configuration" do
      before do
        run_generator
      end

      subject { config }

      it { should match /VALID_CONFIG_OPTIONS\s*=\s*\[[\w\s,:]*:endpoint[\w\s,:]*\]/ }
      it { should match /VALID_CONFIG_OPTIONS\s*=\s*\[[\w\s,:]*:namespace[\w\s,:]*\]/ }
      it { should match /VALID_CONFIG_OPTIONS\s*=\s*\[[\w\s,:]*:username[\w\s,:]*\]/ }
      it { should match /VALID_CONFIG_OPTIONS\s*=\s*\[[\w\s,:]*:password[\w\s,:]*\]/ }
      it { should match /DEFAULT_ENDPOINT\s*=/ }
      it { should match /DEFAULT_NAMESPACE\s*=/ }
      it { should match /def\s+configure/ }
      it { should match /def\s+reset/ }
      it { should match /def\s+options/ }
      it { should match /def\s+debug\?/ }
      it { should match /attr_writer\s+:logger/ }
      it { should match /def\s+logger/ }
    end
  end

  context "without --soap" do
    it 'should create a file for the configuration implementation' do
      expect { subject }.to change { File.file?(config_file) }.from(false).to(true)
    end

    describe "the configuration" do
      before do 
        run_generator
      end

      subject { config }

      it { should_not match /VALID_CONFIG_OPTIONS\s*=\s*\[[\w\s,:]*:endpoint[\w\s,:]*\]/ }
      it { should_not match /VALID_CONFIG_OPTIONS\s*=\s*\[[\w\s,:]*:namespace[\w\s,:]*\]/ }
      it { should_not match /VALID_CONFIG_OPTIONS\s*=\s*\[[\w\s,:]*:username[\w\s,:]*\]/ }
      it { should_not match /VALID_CONFIG_OPTIONS\s*=\s*\[[\w\s,:]*:password[\w\s,:]*\]/ }
      it { should_not match /DEFAULT_ENDPOINT\s*=/ }
      it { should_not match /DEFAULT_NAMESPACE\s*=/ }
      it { should match /def\s+configure/ }
      it { should match /def\s+reset/ }
      it { should match /def\s+options/ }
      it { should match /def\s+debug\?/ }
      it { should match /attr_writer\s+:logger/ }
      it { should match /def\s+logger/ }
    end
  end
end
