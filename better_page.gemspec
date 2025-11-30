require_relative "lib/better_page/version"

Gem::Specification.new do |spec|
  spec.name        = "better_page"
  spec.version     = BetterPage::VERSION
  spec.authors     = [ "alessiobussolari" ]
  spec.email       = [ "alessio.bussolari@pandev.it" ]
  spec.homepage    = "https://github.com/alessiobussolari/better_page"
  spec.summary     = "A structured page object pattern for Rails applications"
  spec.description = "BetterPage provides base classes for creating presentation-layer page objects that separate UI configuration from business logic. Includes generators and compliance analysis tools."
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/alessiobussolari/better_page"
  spec.metadata["changelog_uri"] = "https://github.com/alessiobussolari/better_page/blob/main/CHANGELOG.md"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib,docs,guide}/**/*", "MIT-LICENSE", "Rakefile", "README.md", "CHANGELOG.md"]
  end

  spec.add_dependency "rails", ">= 7.0"
  spec.add_dependency "dry-schema", "~> 1.13"
  spec.add_dependency "view_component", ">= 3.0"
end
