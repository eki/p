
require 'rake'

task :p do
  exec "bin/p"
end

task :q do
  exec "bin/p --no-evaluate"
end

task :r do
  exec "bin/p --reduce"
end

task :test do
  exec "bin/p #{FileList['p/test/**/*.p']}"
end

