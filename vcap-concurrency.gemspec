# -*- encoding: utf-8 -*-
require File.expand_path("../lib/vcap/concurrency/version", __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["mpage"]
  gem.email         = ["mpage@rbcon.com"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "vcap-concurrency"
  gem.require_paths = ["lib"]
  gem.version       = VCAP::Concurrency::VERSION

  gem.add_development_dependency("ci_reporter")
  gem.add_development_dependency("rake")
  gem.add_development_dependency("rspec")
end
