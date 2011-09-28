require 'spec_helper'

describe AdapterGenerator::NewGem do
  let(:project_root) { File.expand_path(File.join(File.dirname(__FILE__), '..', '..')) }
  before { FakeFS::FileSystem.clone(project_root) }

  let(:author_name) { '' }
  let(:author_email) { '' }

  before do
    AdapterGenerator::NewGem.any_instance.stub(:git_user_name).and_return(author_name)
    AdapterGenerator::NewGem.any_instance.stub(:git_user_email).and_return(author_email)
  end

  let(:run_generator) { capture(:stdout) { AdapterGenerator::NewGem.start(args) } }
  subject { run_generator }

  let(:args) { gem_name_arg }

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

  shared_examples_for 'a gemspec generator' do
    let(:gemspec_file) { File.join(gem_path, "#{gem_name}.gemspec") }

    it "should create a file for the gemspec" do
      expect { subject }.to change { File.file?(gemspec_file) }.from(false).to(true)
    end

    describe "the gemspec" do
      before { run_generator }

      subject { File.open(gemspec_file, 'r') { |f| f.read } }

      it { should match /s\.name\s*=\s*"#{gem_name}"/ }
      it { should match /s\.version\s+=\s*#{module_name}::VERSION/ }

      context "without --author_name" do
        context "when the author is in the git config" do
          let(:author_name) { 'Jane Q. Developer' }

          it { should match /s\.authors\s*=\s*\[\s*"#{author_name}"\s*\]/ }
        end

        context "when there is no author in the git config" do
          it { should match /s\.authors\s*=\s*\[\s*".*TODO.*"\s*\]/ }
        end
      end

      context "with --author_name" do
        let(:args) { [gem_name, "--author_name=#{author_name}"] }
        let(:author_name) { 'G5' }

        it { should match /s\.authors\s*=\s*\[\s*"#{author_name}"\s*\]/ }
      end

      context "without --author_email" do
        context "when the author email is in the git config" do
          let(:author_email) { 'jane@test.com' }

          it { should match /s\.email\s*=\s*\[\s*"#{author_email}"\s*\]/ }
        end

        context "when there is no author email in the git config" do
          it { should match /s\.email\s*=\s*\[\s*".*TODO.*"\s*\]/ }
        end
      end

      context "with --author_email" do
        let(:args) { [gem_name, "--author_email=#{author_email}"] }
        let(:author_email) { 'engineering@g5platform.com' }

        it { should match /s\.email\s*=\s*\[\s*"#{author_email}"\s*\]/ }
      end

      it { should match /s\.summary\s*=\s*%q\{.*TODO.*\}/ }
      it { should match /s\.description\s*=\s*%q\{.*TODO.*\}/ }

      context "without --homepage" do
        it { should match /s\.homepage\s*=\s*""/ }
      end

      context "with --homepage" do
        let(:homepage) { 'http://testing.com/my_gem' }
        let(:args) { [gem_name, "--homepage=#{homepage}"] }
        it { should match /s\.homepage\s*=\s*"#{homepage}"/ }
      end

      it { should match /s\.rubyforge_project\s*=\s*"#{gem_name}"/ }

      it { should match /s\.files\s*=/ }
      it { should match /s\.test_files\s*=/ }

      context "without --bin" do
        it { should_not match /s\.executables\s*=/ }
      end

      context "with --bin" do
        let(:args) { [gem_name, '--bin'] }

        it { should match /s\.executables\s*=/ }
      end

      it { should match /s\.require_paths\s*=\s*\["lib"\]/ }
    end
  end

  shared_examples_for 'a Gemfile generator' do
    let(:gemfile) { File.join(gem_path, "Gemfile") }

    it "should create the Gemfile" do
      expect { subject }.to change { File.file?(gemfile) }.from(false).to(true)
    end

    it "should not create the Gemfile.lock" do
      expect { subject }.to_not change { File.file?("#{gemfile}.lock") }
    end

    describe "the Gemfile" do
      before { run_generator }

      subject { File.open(gemfile, 'r') { |f| f.read } }

      it { should match /source\s+"http:\/\/rubygems.org"/ }
      it { should match /gemspec/ }
      it { should_not match /group/ }
      it { should_not match /^\s*gem / }
    end
  end

  context "when gem name argument is in snake case" do
    let(:gem_name_arg) { 'my_gem' }
    let(:gem_name) { gem_name_arg }
    let(:module_name) { 'MyGem' }

    it_should_behave_like 'a gem lib generator'
    it_should_behave_like 'a gemspec generator'
    it_should_behave_like 'a Gemfile generator'
  end

  context "when gem name argument is in camel case" do
    let(:gem_name_arg) { 'MyGem' }
    let(:gem_name) { 'my_gem' }
    let(:module_name) { gem_name_arg }

    it_should_behave_like 'a gem lib generator'
    it_should_behave_like 'a gemspec generator'
    it_should_behave_like 'a Gemfile generator'
  end

  context "when gem name argument is in a hybrid format" do
    let(:gem_name_arg) { 'myGem_is_Awesome' }
    let(:gem_name) { 'my_gem_is_awesome' }
    let(:module_name) { 'MyGemIsAwesome' }

    it_should_behave_like 'a gem lib generator'
    it_should_behave_like 'a gemspec generator'
    it_should_behave_like 'a Gemfile generator'
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