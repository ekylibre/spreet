# encoding: utf-8
Gem::Specification.new do |s|
  s.name = "spreet"
  File.open("VERSION", "rb") do |f|
    s.version = f.read
  end
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.author = "Brice Texier"
  s.email  = "brice.texier@ekylibre.org"
  s.summary = "Spr[eadsh]eet handler"
  s.description = "Spr[eadsh]eet handler for CSV(RW), Excel CSV(RW) and ODS(W)."+
    " The goal is to read and write in many open formats."
  s.extra_rdoc_files = [ "MIT-LICENSE", "README.rdoc" ]
  s.test_files = `git ls-files test/test_*.rb`.split("\n") 
  exclusions = [ "#{s.name}.gemspec", ".travis.yml", ".gitignore", "Gemfile", "Rakefile" ]
  s.files = `git ls-files`.split("\n").delete_if{|f| exclusions.include?(f)}
  s.homepage = "http://github.com/burisu/spreet"
  s.license = "MIT"
  s.require_path = "lib"
  add_runtime_dependency = (s.respond_to?(:add_runtime_dependency) ? :add_runtime_dependency : :add_dependency)
  s.send(add_runtime_dependency, "fastercsv", [">= 0"])
  s.send(add_runtime_dependency, "libxml-ruby", [">= 0"])
  s.send(add_runtime_dependency, "rubyzip", [">= 0.9.4"])
  s.send(add_runtime_dependency, "money", [">= 4.0.0"])
end

