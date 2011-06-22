require 'rake/testtask'
require 'rubygems/package_task'

Rake::TestTask.new

spec = Gem::Specification.load File.expand_path("../cashrb.gemspec", __FILE__)
gem  = Gem::PackageTask.new(spec)
gem.define
