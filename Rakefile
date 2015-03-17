$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'lib'))

require 'rake'
require 'json'
require 'marathon'
require 'rspec/core/rake_task'
require 'vcr'
require 'cane/rake_task'

task :default => [:spec, :quality]

RSpec::Core::RakeTask.new do |t|
  t.pattern = 'spec/**/*_spec.rb'
end

Cane::RakeTask.new(:quality) do |cane|
  cane.canefile = '.cane'
end

dir = File.expand_path(File.dirname(__FILE__))
namespace :vcr do
  desc 'Remove VCR files'
  task :clean do
    FileUtils.remove_dir("#{dir}/fixtures/vcr", true)
  end

  desc 'Preapre Marathon by deploying some tasks'
  task :prepare do
    json = JSON.parse(File.read("#{dir}/fixtures/marathon_docker_sample.json"))
    Marathon::App.new(json).start!

    json = JSON.parse(File.read("#{dir}/fixtures/marathon_docker_sample_2.json"))
    Marathon::App.new(json).start!
  end

  desc 'Run spec tests and record VCR cassettes'
  task :record => [:clean, :prepare, :spec]

end
