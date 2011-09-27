# Thor monkeypatches the core ruby File class to add the binread method for ruby 1.8.7,
# so we have to do the same for FakeFS. (boo)
module FakeFS
  class File
    def self.binread(file)
      File.open(file, 'rb') { |f| f.read }
    end
  end
end
