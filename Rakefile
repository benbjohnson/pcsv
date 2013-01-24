require 'rubygems'
require 'rubygems/package_task'
require 'rake/testtask'

$:.unshift File.join(File.dirname(__FILE__), 'lib')
require 'pcsv/version'

task :default => :test


#############################################################################
#
# Testing tasks
#
#############################################################################

Rake::TestTask.new do |t|
  t.options = "-v"
  t.libs << "test"
  t.test_files = FileList["test/*_test.rb", "test/**/*_test.rb"]
end


#############################################################################
#
# Utility tasks
#
#############################################################################

task :console do
  sh "irb -I lib -r pcsv"
end


#############################################################################
#
# Packaging tasks
#
#############################################################################

task :release do
  puts ""
  print "Are you sure you want to relase PCSV #{PCSV::VERSION}? [y/N] "
  exit unless STDIN.gets.index(/y/i) == 0
  
  unless `git branch` =~ /^\* master$/
    puts "You must be on the master branch to release!"
    exit!
  end
  
  # Build gem and upload
  sh "gem build pcsv.gemspec"
  sh "gem push pcsv-#{PCSV::VERSION}.gem"
  sh "rm pcsv-#{PCSV::VERSION}.gem"
  
  # Commit
  sh "git commit --allow-empty -a -m 'v#{PCSV::VERSION}'"
  sh "git tag v#{PCSV::VERSION}"
  sh "git push origin master"
  sh "git push origin v#{PCSV::VERSION}"
end
