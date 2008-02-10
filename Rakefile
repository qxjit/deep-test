require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rake/gempackagetask'
require 'rake/contrib/sshpublisher'
$LOAD_PATH << File.dirname(__FILE__) + "/lib"
require "deep_test/rake_tasks"

task :default => %w[test failing_test deep_test]

Rake::TestTask.new do |t|
  t.pattern = "test/**/*_test.rb"
  t.libs += ['test', 'lib']
end

DeepTest::TestTask.new :deep_test do |t|
  t.number_of_workers = 2
  t.pattern = "test/**/*_test.rb"
end

DeepTest::TestTask.new :deep_test_failing do |t|
  t.number_of_workers = 1
  t.pattern = "test/failing.rb"
end

# TODO: figure out a better way to test this that doesn't
#       involve having a failing test in the output of 'rake test'
task :failing_test do
  exception = nil
  begin
    Rake::Task[:deep_test_failing].invoke
  rescue => exception
  end
  fail "exception should not be nil" if exception.nil?
end

desc "Generate documentation"
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = "doc"
  rdoc.title    = "DeepTest"
  rdoc.options << '--line-numbers'
  rdoc.rdoc_files.include('README', 'CHANGELOG')
end

desc "Upload RDoc to RubyForge"
task :publish_rdoc => [:rdoc] do
  Rake::SshDirPublisher.new("dcmanges@rubyforge.org", "/var/www/gforge-projects/deep-test", "doc").upload
end

Gem::manage_gems

specification = Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
	s.name   = "deep_test"
  s.summary = "DeepTest runs tests in multiple processes."
	s.version = "1.1.1"
	s.author = "anonymous z, Dan Manges, David Vollbracht"
	s.description = s.summary
	s.email = "daniel.manges@gmail.com"
  s.homepage = "http://deep-test.rubyforge.org"
  s.rubyforge_project = "deep-test"

  s.has_rdoc = true
  s.extra_rdoc_files = ['README', 'CHANGELOG']
  s.rdoc_options << '--title' << "DeepTest" << '--main' << 'README' << '--line-numbers'

  s.autorequire = "deep_test"
  s.files = FileList['{lib,script,test}/**/*.{rb,rake}', 'README', 'CHANGELOG', 'Rakefile'].to_a
end

Rake::GemPackageTask.new(specification) do |package|
  package.need_zip = true
  package.need_tar = true
end

Rake::Task[:gem].prerequisites.unshift :deep_test
Rake::Task[:gem].prerequisites.unshift :test

task :tar do
  system "tar zcf pkg/deep_test.tar.gz --exclude=.svn --exclude='*.tar.gz' --exclude='*.gem' --directory=.. deep_test"
end
