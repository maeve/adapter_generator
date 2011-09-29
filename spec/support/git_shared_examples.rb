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
    it { should match /doc/ }
  end

  it 'should initialize a new git repo' do
    AdapterGenerator::NewGem.any_instance.should_receive(:initialize_git).at_least(:once)
    subject
  end
end
