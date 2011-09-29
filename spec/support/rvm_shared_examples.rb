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
