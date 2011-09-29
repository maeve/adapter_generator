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
