require 'spec_helper'

describe AdapterGenerator::NewGem do
  # These aren't really unit tests, since thor manages so much of the object
  # lifecycle. These are more like functional tests: multiple pieces of code
  # may be executed for each example, but external resources are mocked..

  let(:project_root) { File.expand_path(File.join(File.dirname(__FILE__), '..', '..')) }
  before { FakeFS::FileSystem.clone(project_root) }

  let(:author_name) { '' }
  let(:author_email) { '' }

  before do
    AdapterGenerator::NewGem.any_instance.stub(:git_user_name).and_return(author_name)
    AdapterGenerator::NewGem.any_instance.stub(:git_user_email).and_return(author_email)
    AdapterGenerator::NewGem.any_instance.stub(:make_bin_executable).and_return(nil)
    AdapterGenerator::NewGem.any_instance.stub(:initialize_git).and_return(nil)
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

      it { should match /\.name\s*=\s*"#{gem_name}"/ }
      it { should match /\.version\s+=\s*#{module_name}::VERSION/ }

      context "without --author_name" do
        context "when the author is in the git config" do
          let(:author_name) { 'Jane Q. Developer' }

          it { should match /\.authors\s*=\s*\[\s*"#{author_name}"\s*\]/ }
        end

        context "when there is no author in the git config" do
          it { should match /\.authors\s*=\s*\[\s*".*TODO.*"\s*\]/ }
        end
      end

      context "with --author_name" do
        let(:args) { [gem_name, "--author_name=#{author_name}"] }
        let(:author_name) { 'G5' }

        it { should match /\.authors\s*=\s*\[\s*"#{author_name}"\s*\]/ }
      end

      context "without --author_email" do
        context "when the author email is in the git config" do
          let(:author_email) { 'jane@test.com' }

          it { should match /\.email\s*=\s*\[\s*"#{author_email}"\s*\]/ }
        end

        context "when there is no author email in the git config" do
          it { should match /\.email\s*=\s*\[\s*".*TODO.*"\s*\]/ }
        end
      end

      context "with --author_email" do
        let(:args) { [gem_name, "--author_email=#{author_email}"] }
        let(:author_email) { 'engineering@g5platform.com' }

        it { should match /\.email\s*=\s*\[\s*"#{author_email}"\s*\]/ }
      end

      it { should match /\.summary\s*=\s*%q\{.*TODO.*\}/ }
      it { should match /\.description\s*=\s*%q\{.*TODO.*\}/ }

      context "without --homepage" do
        it { should match /\.homepage\s*=\s*""/ }
      end

      context "with --homepage" do
        let(:homepage) { 'http://testing.com/my_gem' }
        let(:args) { [gem_name, "--homepage=#{homepage}"] }
        it { should match /\.homepage\s*=\s*"#{homepage}"/ }
      end

      it { should match /\.rubyforge_project\s*=\s*"#{gem_name}"/ }

      it { should match /\.files\s*=/ }
      it { should match /\.test_files\s*=/ }

      context "without --bin" do
        it { should_not match /\.executables\s*=/ }
      end

      context "with --bin" do
        let(:args) { [gem_name, '--bin'] }

        it { should match /\.executables\s*=/ }
      end

      it { should match /\.require_paths\s*=\s*\[["']lib["']\]/ }

      it { should match /\.add_development_dependency\(\s*["']rspec['"]/ }
      it { should match /\.add_development_dependency\(\s*["']webmock['"]/ }
      it { should match /\.add_development_dependency\(\s*["']fakefs['"]/ }
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

  shared_examples_for 'a bin generator' do
    let(:bin_path) { File.join(gem_path, 'bin') }
    let(:bin_file) { File.join(bin_path, gem_name) }

    context "with --bin" do
      let(:args) { [gem_name, '--bin'] }

      it "should create the bin directory" do
        expect { subject }.to change { Dir.exists?(bin_path) }.from(false).to(true)
      end

      it "should create a bin file in the appropriate location" do
        expect { subject }.to change { File.file?(bin_file) }.from(false).to(true)
      end

      # TODO: verify that the bin file is executable when FakeFS supports file permissions: https://github.com/defunkt/fakefs/issues/73

      describe "the binfile" do
        before { run_generator }

        subject { File.open(bin_file, 'r') { |f| f.read } }

        it { should match /^#!\/usr\/bin\/env\s+ruby/ }
        it { should match /^\s*require\s+["']#{gem_name}["']/ }
      end
    end

    context "without --bin" do
      it "should not create a binfile" do
        expect { subject }.to_not change { File.file?(bin_file) }
      end
    end
  end

  shared_examples_for 'a Rakefile generator' do
    let(:rakefile) { File.join(gem_path, 'Rakefile') }

    it 'should create a Rakefile' do
      expect { subject }.to change { File.file?(rakefile) }.from(false).to(true)
    end

    describe 'the Rakefile' do
      before { run_generator }

      subject { File.open(rakefile, 'r') { |f| f.read } }

      it { should match /require\s+['"]bundler\/gem_tasks['"]/ }

      it { should match /require\s+['"]rspec\/core\/rake_task["']/ }
      it { should match /RSpec::Core::RakeTask.new\(\s*:spec\s*\)/ }
      it { should match /task\s+:default\s*=>\s*:spec/ }
    end
  end

  shared_examples_for 'a rvm configurer' do
    let(:rvmrc) { File.join(gem_path, '.rvmrc') }
    let(:rvmrc_contents) { File.open(rvmrc, 'r') { |f| f.read } }

    context 'when there is no --ruby' do
      it 'should create an rvmrc file' do
        expect { subject }.to change { File.file?(rvmrc) }.from(false).to(true)
      end

      describe "the .rvmrc file" do
        before { run_generator }
        subject { rvmrc_contents }

        it { should match /rvm\s+--create\s+use\s+1\.8\.7@#{gem_name}/ }
      end
    end

    context 'when --ruby is set to 1.9.2' do
      let(:args) { [gem_name, '--ruby=1.9.2'] }

      it 'should create an rvmrc file' do
        expect { subject }.to change { File.file?(rvmrc) }.from(false).to(true)
      end

      describe "the .rvmrc file" do
        before { run_generator }
        subject { rvmrc_contents }

        it { should match /rvm\s+--create\s+use\s+1\.9\.2@#{gem_name}/ }
      end
    end

    context 'when --ruby is set to ree-1.8.7-2010.02' do
      let(:args) { [gem_name, '--ruby=ree-1.8.7-2010.02'] }

      it 'should create an rvmrc file' do
        expect { subject }.to change { File.file?(rvmrc) }.from(false).to(true)
      end

      describe "the .rvmrc file" do
        before { run_generator }
        subject { rvmrc_contents }

        it { should match /rvm\s+--create\s+use\s+ree-1\.8\.7-2010\.02@#{gem_name}/ }
      end
    end
  end

  shared_examples_for 'a rspec configurer' do
    let(:spec_path) { File.join(gem_path, 'spec') }
    let(:spec_helper) { File.join(spec_path, 'spec_helper.rb') }
    let(:top_spec) { File.join(spec_path, "#{gem_name}_spec.rb") }

    it "should create the .rspec config file" do
      expect { subject }.to change { File.file?(File.join(gem_path, '.rspec')) }.from(false).to(true)
    end

    it "should create the spec directory" do
      expect { subject }.to change { Dir.exists?(spec_path) }.from(false).to(true)
    end

    it "should create the spec_helper.rb" do
      expect { subject }.to change { File.file?(spec_helper) }.from(false).to(true)
    end

    describe "the spec_helper.rb" do
      before { run_generator }
      subject { File.open(spec_helper, 'r') { |f| f.read } }

      it { should match /require\s+['"]rspec['"]/ }
      it { should match /require\s+['"]fakefs\/spec_helpers['"]/ }
      it { should match /require\s+['"]webmock\/rspec['"]/ }
      it { should match /require\s+['"]#{gem_name}['"]/ }
      it { should match /RSpec\.configure\s+do\s+\|config\|/ }
      it { should match /config\.include\s+FakeFS::SpecHelpers\s+/ }
    end

    it "should create the top-level spec" do
      expect { subject }.to change { File.file?(File.join(top_spec)) }.from(false).to(true)
    end

    describe "the top-level spec" do
      before { run_generator }
      subject { File.open(top_spec, 'r') { |f| f.read } }

      it { should match /require\s+['"]spec_helper['"]/ }
      it { should match /describe #{module_name} do/ }
      it { should match /it ['"]should/ }
    end

    it "should create the support directory" do
      expect { subject }.to change { Dir.exists?(File.join(spec_path, 'support')) }.from(false).to(true)
    end

    it "should create the directory for the remaining specs" do
      expect { subject }.to change { Dir.exists?(File.join(spec_path, gem_name)) }.from(false).to(true)
    end
  end

  shared_examples_for 'a git initializer' do
    let(:gitignore) { File.join(gem_path, '.gitignore') }

    it 'should create a .gitignore file' do
      expect { subject }.to change { File.file?(gitignore) }.from(false).to(true)
    end

    describe 'the .gitignore file' do
      before { run_generator }

      subject { File.open(gitignore, 'r') { |f| f.read } }

      it { should match /\.bundle/ }
      it { should match /pkg/ }
      it { should match /\*\.gem/ }
      it { should match /Gemfile\.lock/ }
    end

    it 'should initialize a new git repo' do
      AdapterGenerator::NewGem.any_instance.should_receive(:initialize_git).at_least(:once)
      subject
    end
  end

  context "when gem name argument is in snake case" do
    let(:gem_name_arg) { 'my_gem' }
    let(:gem_name) { gem_name_arg }
    let(:module_name) { 'MyGem' }

    it_should_behave_like 'a gem lib generator'
    it_should_behave_like 'a gemspec generator'
    it_should_behave_like 'a Gemfile generator'
    it_should_behave_like 'a bin generator'
    it_should_behave_like 'a Rakefile generator'
    it_should_behave_like 'a rvm configurer'
    it_should_behave_like 'a rspec configurer'
    it_should_behave_like 'a git initializer'
  end

  context "when gem name argument is in camel case" do
    let(:gem_name_arg) { 'MyGem' }
    let(:gem_name) { 'my_gem' }
    let(:module_name) { gem_name_arg }

    it_should_behave_like 'a gem lib generator'
    it_should_behave_like 'a gemspec generator'
    it_should_behave_like 'a Gemfile generator'
    it_should_behave_like 'a bin generator'
    it_should_behave_like 'a Rakefile generator'
    it_should_behave_like 'a rvm configurer'
    it_should_behave_like 'a rspec configurer'
    it_should_behave_like 'a git initializer'
  end

  context "when gem name argument is in a hybrid format" do
    let(:gem_name_arg) { 'myGem_is_Awesome' }
    let(:gem_name) { 'my_gem_is_awesome' }
    let(:module_name) { 'MyGemIsAwesome' }

    it_should_behave_like 'a gem lib generator'
    it_should_behave_like 'a gemspec generator'
    it_should_behave_like 'a Gemfile generator'
    it_should_behave_like 'a bin generator'
    it_should_behave_like 'a Rakefile generator'
    it_should_behave_like 'a rvm configurer'
    it_should_behave_like 'a rspec configurer'
    it_should_behave_like 'a git initializer'
  end

  describe "#setup_dependencies" do
    # TODO
  end

  describe "#setup_docs" do
    # TODO
  end
end
