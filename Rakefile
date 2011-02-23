require 'rake/testtask'
require 'rake/gempackagetask'

Rake::TestTask.new

spec = Gem::Specification.load File.expand_path("../cash.gemspec", __FILE__)
gem  = Rake::GemPackageTask.new(spec)
gem.define
