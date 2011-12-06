Gem::Specification.new do |s|
  s.name        = "cashrb"
  s.version     = "1.3.0"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Shane Emmons"]
  s.email       = ["semmons99@gmail.com"]
  s.homepage    = "http://semmons99.github.com/cashrb/"
  s.summary     = "Lightweight money and currency handler for working with financial calculations."
  s.description = "Lightweight money and currency handler for working with financial calculations."

  s.required_ruby_version     = ">= 1.8.7"
  s.required_rubygems_version = ">= 1.3.6"

  s.add_development_dependency "minitest", "~> 2.2.0"

  s.files =  Dir.glob("{lib,test}/**/*")
  s.files += %w(CHANGELOG.md LICENSE README.md)
  s.files += %w(Rakefile .gemtest cashrb.gemspec)

  s.require_path = "lib"
end
