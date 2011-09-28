require 'thor/group'
require 'active_support/core_ext/string'

module AdapterGenerator
  class NewGem < Thor::Group
    include Thor::Actions

    desc 'Generates a skeletal project for a new third-party adapter'
    argument :name, :desc => 'The name of the new adapter'

    class_option :author_name, :type => :string, :desc => "the gem author's name (defaults to git config user.name)"
    class_option :author_email, :type => :string, :desc => "the gem author's email (defaults to git config user.email)"
    class_option :homepage, :type => :string, :desc => "the homepage URL for the project"
    class_option :bin, :type => :boolean, :default => false, :aliases => "-b", :banner => "Generate a binary for your library"

    def self.source_root
      File.expand_path(File.join(File.dirname(__FILE__), 'templates'))
    end

    def create_lib
      opts = {:name => name.underscore, :constant => name.camelize}
      target = File.join(gem_path, 'lib')

      template(File.join('lib', 'new_gem.rb.tt'), File.join(target, "#{opts[:name]}.rb"), opts)
      template(File.join('lib', 'new_gem', 'version.rb.tt'), File.join(target, opts[:name], 'version.rb'), opts)
    end

    def create_gemspec
      opts = {:name => name.underscore,
              :constant => name.camelize,
              :author_name => options[:author_name] || git_user_name,
              :author_email => options[:author_email] || git_user_email,
              :homepage => options[:homepage],
              :bin => options[:bin] }

      opts[:author_name] = "TODO: enter your name" if opts[:author_name].blank?
      opts[:author_email] = "TODO: enter your email address" if opts[:author_email].blank?

      template('new_gem.gemspec.tt', File.join(gem_path, "#{opts[:name]}.gemspec"), opts)
    end

    def create_gemfile
      opts = {:name => name.underscore}
      template('Gemfile.tt', File.join(gem_path, 'Gemfile'), opts)
    end

    def create_bin
      if options[:bin]
        opts = {:name => name.underscore}
        target = File.join(gem_path, 'bin', opts[:name])
        template('bin/new_gem.tt', target, opts)
        make_bin_executable
      end
    end

    private
    def gem_path
      File.join(Dir.pwd, name.underscore)
    end

    def git_user_name
      `git config user.name`.chomp
    end

    def git_user_email
      `git config user.email`.chomp
    end

    def make_bin_executable
      chmod(File.join(gem_path, 'bin', name.underscore), 0755)
    end
  end
end
