require 'spec_helper'

describe AdapterGenerator::NewGem do
  # These aren't really unit tests. Thor manages so much of the object's lifecycle
  # that mocking out collaborators would require intimate knowledge of thor internals.
  # Instead, these are more like functional tests: multiple pieces of code
  # may be executed for each example, but external resources (the filesystem, etc.) are mocked.

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

  context "when gem name argument is in snake case" do
    let(:gem_name_arg) { 'my_gem' }
    let(:gem_name) { gem_name_arg }
    let(:module_name) { 'MyGem' }
    let(:human_name) { 'My Gem' }

    it_should_behave_like 'a gem lib generator'
    it_should_behave_like 'a gemspec generator'
    it_should_behave_like 'a Gemfile generator'
    it_should_behave_like 'a bin generator'
    it_should_behave_like 'a Rakefile generator'
    it_should_behave_like 'a rvm configurer'
    it_should_behave_like 'a rspec configurer'
    it_should_behave_like 'a doc generator'
    it_should_behave_like 'a git initializer'
  end

  context "when gem name argument is in camel case" do
    let(:gem_name_arg) { 'MyGem' }
    let(:gem_name) { 'my_gem' }
    let(:module_name) { gem_name_arg }
    let(:human_name) { 'My Gem' }

    it_should_behave_like 'a gem lib generator'
    it_should_behave_like 'a gemspec generator'
    it_should_behave_like 'a Gemfile generator'
    it_should_behave_like 'a bin generator'
    it_should_behave_like 'a Rakefile generator'
    it_should_behave_like 'a rvm configurer'
    it_should_behave_like 'a rspec configurer'
    it_should_behave_like 'a doc generator'
    it_should_behave_like 'a git initializer'
  end

  context "when gem name argument is in a hybrid format" do
    let(:gem_name_arg) { 'myGem_is_Awesome' }
    let(:gem_name) { 'my_gem_is_awesome' }
    let(:module_name) { 'MyGemIsAwesome' }
    let(:human_name) { 'My Gem Is Awesome' }

    it_should_behave_like 'a gem lib generator'
    it_should_behave_like 'a gemspec generator'
    it_should_behave_like 'a Gemfile generator'
    it_should_behave_like 'a bin generator'
    it_should_behave_like 'a Rakefile generator'
    it_should_behave_like 'a rvm configurer'
    it_should_behave_like 'a rspec configurer'
    it_should_behave_like 'a doc generator'
    it_should_behave_like 'a git initializer'
  end
end
