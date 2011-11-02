# encoding: utf-8
Gem::Specification.new do |s|
  s.name = "spreet"
  File.open("VERSION", "rb") do |f|
    s.version = f.read
  end
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Brice Texier"]
  s.email  = ["brice.texier@ekylibre.org"]
  s.summary = "Spr[eadsh]eet handler"
  s.description = "Spr[eadsh]eet handler for CSV(RW), Excel CSV(RW) and ODS(W). The goal is to read and write in many open formats."
  s.email = "brice.texier@ekylibre.org"
  s.extra_rdoc_files = [
    "MIT-LICENSE",
    "README.rdoc"
  ]
  s.test_files = `git ls-files test/test_*.rb`.split("\n") 
  exclusions = [ "#{s.name}.gemspec", ".travis.yml", ".gitignore", "Gemfile", "Rakefile" ]
  s.files = `git ls-files`.split("\n").delete_if{|f| exclusions.include?(f)}
  s.homepage = "http://github.com/burisu/spreet"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]

  if s.respond_to? :specification_version then
    s.specification_version = 3
    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency("fastercsv", [">= 0"])
      s.add_runtime_dependency("libxml-ruby", [">= 0"])
      s.add_runtime_dependency("rubyzip", [">= 0.9.4"])
    else
      s.add_dependency("fastercsv", [">= 0"])
      s.add_dependency("libxml-ruby", [">= 0"])
      s.add_dependency("rubyzip", [">= 0.9.4"])
    end
  else
    s.add_dependency("fastercsv", [">= 0"])
    s.add_dependency("libxml-ruby", [">= 0"])
    s.add_dependency("rubyzip", [">= 0.9.4"])
  end
end

