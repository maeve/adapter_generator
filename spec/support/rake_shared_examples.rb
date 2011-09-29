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

    it { should match /namespace\s+:doc/ }
    it { should match /require\s+['"]yard['"]/ }
    it { should match /YARD::Rake::YardocTask\.new/ }
  end
end
