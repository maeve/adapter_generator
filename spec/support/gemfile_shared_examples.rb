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
