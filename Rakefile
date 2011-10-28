
require 'rake'
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/**/*_test.rb']
  t.verbose = true
end

task :p do
  exec "bin/p"
end

task :q do
  exec "bin/p --no-evaluate"
end

task :r do
  exec "bin/p --reduce"
end

