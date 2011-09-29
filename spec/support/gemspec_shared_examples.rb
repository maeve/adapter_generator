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

    it { should match /\.add_development_dependency\(\s*["']yard['"]/ }
    it { should match /\.add_development_dependency\(\s*["']rdiscount['"]/ }

    context "with --soap" do
      let(:args) { [gem_name, '--soap'] }

      it { should match /\.add_dependency\(\s*['"]savon['"]/ }
      it { should match /\.add_development_dependency\(\s*['"]savon_spec['"]/ }
    end

    context "without --soap" do
      it { should_not match /\.add_[a-z_]*dependency\(\s*['"]savon['"]/ }
      it { should_not match /\.add_[a-z_]*dependency\(\s*['"]savon_spec['"]/ }
    end

    it { should match /\.add_dependency\(\s*['"]modelish['"]/ }
  end
end
