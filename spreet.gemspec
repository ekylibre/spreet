# encoding: utf-8
$:.push File.expand_path("../lib", __FILE__)
require "spreet/version"

Gem::Specification.new do |spec|
  spec.name = "spreet"
  spec.version = Spreet::VERSION::STRING
  spec.required_rubygems_version = ">= 1.9.2"
  spec.author = "Brice Texier"
  spec.email  = "brice.texier@ekylibre.org"
  spec.summary = "Spr[eadsh]eet handler"
  spec.description = "Spr[eadsh]eet handler for CSV(RW), Excel CSV(RW) and ODS(RW)."+
    " The goal is to read and write in many open formats."
  spec.extra_rdoc_files = [ "MIT-LICENSE", "README.rdoc" ]
  spec.test_files = `git ls-files test/test_*.rb`.split("\n") 
  exclusions = [ "#{spec.name}.gemspec", ".travis.yml", ".gitignore", "Gemfile", "Rakefile" ]
  spec.files = `git ls-files`.split("\n").delete_if{|f| exclusions.include?(f)}
  spec.homepage = "http://github.com/burisu/spreet"
  spec.license = "MIT"
  spec.require_path = "lib"
  spec.add_dependency("libxml-ruby", [">= 0"])
  spec.add_dependency("rubyzip", [">= 1.0.0"])
  spec.add_dependency("money", [">= 4.0.0"])
  spec.add_dependency("i18n", ["< 0.7.0"])
  spec.add_development_dependency('minitest')
  spec.add_development_dependency('rake', '>= 10')
  spec.add_development_dependency('bundler', '> 1')  
end

