Gem::Specification.new do |s|
  s.name        = "cashrb"
  s.version     = "1.0.2"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Shane Emmons"]
  s.email       = ["semmons99@gmail.com"]
  s.homepage    = "http://github.com/semmons99/cashrb"
  s.summary     = "Dead simple gem to work with Money/Currency without the hassle of Floats"
  s.description = "Dead simple gem to work with Money/Currency without the hassle of Floats"

  s.required_ruby_version     = ">= 1.8.7"
  s.required_rubygems_version = ">= 1.3.6"

  s.requirements << "minitest"

  s.files =  Dir.glob("{lib,test}/**/*")
  s.files += %w(CHANGELOG.md LICENSE README.md)
  s.files += %w(Rakefile .gemtest cashrb.gemspec)

  s.require_path = "lib"
end
