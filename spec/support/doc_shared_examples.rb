shared_examples_for 'a doc generator' do
  let(:readme) { File.join(gem_path, 'README.md') }

  it "should create the README.md" do
    expect { subject }.to change { File.file?(readme) }.from(false).to(true)
  end

  describe "the README.md" do
    before { run_generator }

    subject { File.open(readme) { |f| f.read } }

    it { should match /#\s+#{human_name}\s+#/ }
    it { should match /TODO/ }
  end
end
