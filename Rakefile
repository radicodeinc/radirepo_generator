
require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList['test/**/*_test.rb']
end

task :default => :test


task :generate do
  result = DailyReportGenerator::Generator.generate(
    github_events: DailyReportGenerator::Github.events
  )

  puts result
end

