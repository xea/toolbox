require 'rspec/core/rake_task'

desc "test ALL the things"
RSpec::Core::RakeTask.new(:spec) do |t, task_args|
    ENV["LC_ALL"] = "en_US.UTF-8"
    t.rspec_opts = "-I ./packages/"
    t.pattern = "{spec,packages}/**/*_spec.rb"
end
