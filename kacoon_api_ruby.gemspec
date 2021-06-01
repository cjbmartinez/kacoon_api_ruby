$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "kacoon_api_ruby/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = "kacoon_api_ruby"
  spec.version     = KacoonApiRuby::VERSION
  spec.authors     = ["Charles Martinez
"]
  spec.email       = ["cjbmartinez.dev@gmail.com"]
  spec.homepage    = "https://github.com/cjbmartinez"
  spec.summary     = "API Client for Kacoon API Ruby"
  spec.description = "Provides authentication and payment processing using Kacoon API"
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "rails", "~> 5.2.3"
  spec.add_dependency 'http', '~> 4.0'

  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "awesome_print"
end
