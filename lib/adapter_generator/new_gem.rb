require 'thor/group'
require 'active_support/core_ext/string'

module AdapterGenerator
  class NewGem < Thor::Group
    include Thor::Actions

    desc 'Generates a skeletal project for a new third-party adapter'
    argument :name, :desc => 'The name of the new adapter'

    def self.source_root
      File.expand_path(File.join(File.dirname(__FILE__), 'templates'))
    end

    def create_lib
      opts = {:name => name.underscore, :constant => name.camelize}

      target = File.join(Dir.pwd, opts[:name], 'lib')

      template(File.join('lib', 'new_gem.rb.tt'), File.join(target, "#{opts[:name]}.rb"), opts)
      template(File.join('lib', 'new_gem', 'version.rb.tt'), File.join(target, opts[:name], 'version.rb'), opts)
    end
  end
end
