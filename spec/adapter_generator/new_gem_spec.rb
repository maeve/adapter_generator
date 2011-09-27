require 'spec_helper'

describe AdapterGenerator::NewGem do
  let(:project_root) { File.expand_path(File.join(File.dirname(__FILE__), '..', '..')) }
  before { FakeFS::FileSystem.clone(project_root) }

  let(:run_generator) { capture(:stdout) { AdapterGenerator::NewGem.start(args) } }
  subject { run_generator }

  let(:args) { [gem_name_arg] }

  let(:gem_path) { File.expand_path(gem_name) }
  let(:lib_path) { File.join(gem_path, 'lib') }

  shared_examples_for 'a gem lib generator' do
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

  context "when gem name argument is in snake case" do
    let(:gem_name_arg) { 'my_gem' }
    let(:gem_name) { gem_name_arg }
    let(:module_name) { 'MyGem' }

    it_should_behave_like 'a gem lib generator'
  end

  context "when gem name argument is in camel case" do
    let(:gem_name_arg) { 'MyGem' }
    let(:gem_name) { 'my_gem' }
    let(:module_name) { gem_name_arg }

    it_should_behave_like 'a gem lib generator'
  end

  context "when gem name argument is in a hybrid format" do
    let(:gem_name_arg) { 'myGem_is_Awesome' }
    let(:gem_name) { 'my_gem_is_awesome' }
    let(:module_name) { 'MyGemIsAwesome' }

    it_should_behave_like 'a gem lib generator'
  end



  describe "#setup_git" do
    # TODO
  end

  describe "#setup_rake" do
    # TODO
  end

  describe "#setup_dependencies" do
    # TODO
  end

  describe "#setup_ruby" do
    # TODO
  end

  describe "#setup_tests" do
    # TODO
  end

  describe "#setup_docs" do
    # TODO
  end

  describe "#create_bin" do
    # TODO: this will be optional
  end
end
