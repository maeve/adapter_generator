shared_examples_for 'a gem lib generator' do
  let(:lib_path) { File.join(gem_path, 'lib') }

  it "should create a directory for the new gem" do
    expect { subject }.to change { File.directory?(gem_path) }.from(false).to(true)
  end

  it "should create a lib directory" do
    expect { subject }.to change { File.directory?(lib_path) }.from(false).to(true)
  end

  it "should create a file for the top-level module" do
    expect { subject }.to change { File.file?(File.join(lib_path, "#{gem_name}.rb")) }.from(false).to(true)
  end

  it "should create a version file for the gem" do
    expect { subject }.to change { File.file?(File.join(lib_path, gem_name, 'version.rb')) }.from(false).to(true)
  end

  describe "the generated module" do
    before do
      run_generator
      $:.push(lib_path)
      require gem_name
    end

    subject { Object.const_get(module_name) }

    it { should be_a Module } # is this the best way to test for existence?

    it "should have the correct default version" do
      subject::VERSION.should == '0.0.1'
    end
  end
end
