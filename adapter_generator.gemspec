# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "adapter_generator/version"

Gem::Specification.new do |s|
  s.name        = "adapter_generator"
  s.version     = AdapterGenerator::VERSION
  s.authors     = ["maeve"]
  s.email       = ["maeve.revels@g5platform.com"]
  s.homepage    = ""
  s.summary     = %q{A generator for new adapter gems}
  s.description = %q{Generates a skeletal adapter for input from a third-party source (e.g. a SOAP service).}

  s.rubyforge_project = "adapter_generator"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency('thor', '~>0.14')
  s.add_dependency('activesupport', '~>3.0')
  s.add_dependency('i18n', '~>0.5')

  s.add_development_dependency('yard','~>0.7')
  s.add_development_dependency('rdiscount', '~>1.6')

  s.add_development_dependency('rspec','~>2.6')
  s.add_development_dependency('webmock','~>1.7')
  s.add_development_dependency('fakefs','~>0.4')
  s.add_development_dependency('fakefs-require','~>0.2')

  s.add_development_dependency('savon','~>0.9.7')
  s.add_development_dependency('savon_spec','~>0.1')
end
