require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rake/gempackagetask'
require 'rake/contrib/sshpublisher'
require 'yaml'
$LOAD_PATH << File.dirname(__FILE__) + "/lib"
require "deep_test/rake_tasks"

task :default => %w[
  test 
  spec 
  failing_test
  deep_test
  deep_spec
  distributed_test
  distributed_spec
  distributed_with_failover
  test_rails_project
]

task :pc => :default

Rake::TestTask.new do |t|
  t.pattern = "test/**/*_test.rb"
  t.libs += ['test', 'lib']
end

DeepTest::TestTask.new :deep_test do |t|
  t.pattern = "test/**/*_test.rb"
  t.metrics_file = "deep_test.metrics"
end

DeepTest::TestTask.new(:manual_distributed_test) do |t|
  t.pattern = "test/**/*_test.rb"
  t.distributed_hosts = (ENV['HOSTS'] || '').split(' ')
  t.sync_options = {:source => File.dirname(__FILE__), 
                    :username => ENV['USERNAME'],
                    :rsync_options => "--exclude=.svn"}
end

DeepTest::TestTask.new(:distributed_test) do |t|
  t.pattern = "test/**/*_test.rb"
  t.distributed_hosts = %w[localhost]
  t.sync_options = {:source => File.dirname(__FILE__), 
                    :rsync_options => "--exclude=.svn"}
end

def rspec_present?
  defined?(Spec)
end

if rspec_present?
  Spec::Rake::SpecTask.new(:spec) do |t|
    t.spec_files = FileList['spec/**/*_spec.rb']
  end
  
  Spec::Rake::SpecTask.new(:deep_spec) do |t|
    t.spec_files = FileList['spec/**/*_spec.rb']
  end

  Spec::Rake::SpecTask.new(:distributed_spec) do |t|
    t.spec_files = FileList['spec/**/*_spec.rb']
    t.deep_test :distributed_hosts => %w[localhost],
                :sync_options => {:source => File.dirname(__FILE__), 
                                  :rsync_options => "--exclude=.svn"}
  end
end

task :distributed_with_failover do |t|
  puts
  puts "*** Running distributed with no server - expect a failover message ***"
  puts

  Spec::Rake::SpecTask.new(:distributed_spec_with_failover_spec) do |t|
    t.spec_files = FileList['spec/**/*_spec.rb']
    t.deep_test :distributed_hosts => %w[foobar_host],
                :sync_options => {:source => File.dirname(__FILE__), 
                                  :rsync_options => "--exclude=.svn"}
  end
  Rake::Task[:distributed_spec_with_failover_spec].execute "dummy arg"
end

if rspec_present?
  Spec::Rake::SpecTask.new(:distributed_with_host_down) do |t|
    t.spec_files = FileList['spec/**/*_spec.rb']
    t.deep_test :distributed_hosts => %w[localhost foobar_host],
                :sync_options => {:source => File.dirname(__FILE__), 
                                  :rsync_options => "--exclude=.svn"}
  end
end

task :failing_test do
  command = "rake --rakefile test/failing.rake 2>&1"
  puts command
  `#{command}`
  if $?.success?
    puts "F"
    fail "****\ntest/failing.rake should have failed\n****"
  else
    puts "."
  end
end

Rake::TestTask.new(:test_rails_project) do |t|
  t.pattern = "sample_rails_project/deep_test.rb"
end

desc "Generate documentation"
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = "doc"
  rdoc.title    = "DeepTest"
  rdoc.options << '--line-numbers'
  rdoc.rdoc_files.include(
    'README.rdoc', 
    'CHANGELOG', 
    'lib/deep_test/null_worker_listener.rb',
    'lib/deep_test/database/*.rb'
  )
end

desc "Upload RDoc to RubyForge"
task :publish_rdoc => [:rerdoc] do
  rubyforge_config = "#{ENV['HOME']}/.rubyforge/user-config.yml"
  username = YAML.load_file(rubyforge_config)["username"]
  sh "chmod -R 775 doc"
  sh "scp -rqp doc/* #{username}@rubyforge.org:/var/www/gforge-projects/deep-test"
end

Gem::manage_gems

specification = Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
	s.name   = "deep_test"
  s.summary = "DeepTest runs tests in multiple processes."
	s.version = "1.2.2"
	s.author = "anonymous z, Dan Manges, David Vollbracht"
	s.description = s.summary
	s.email = "daniel.manges@gmail.com"
  s.homepage = "http://deep-test.rubyforge.org"
  s.rubyforge_project = "deep-test"
  s.executables << "deep_test"

  s.has_rdoc = true
  s.extra_rdoc_files = ['README.rdoc', 'CHANGELOG']
  s.rdoc_options << '--title' << "DeepTest" << '--main' << 'README.rdoc' << '--line-numbers'

  s.files = FileList['{lib,script,test,bin}/**/*.{rb,rake,rhtml}', 'README.rdoc', 'CHANGELOG', 'Rakefile'].to_a
end

Rake::GemPackageTask.new(specification) do |package|
  package.need_zip = true
  package.need_tar = true
end

Rake::Task[:gem].prerequisites.unshift :default

task :tar do
  system "tar zcf pkg/deep_test.tar.gz --exclude=.svn --exclude='*.tar.gz' --exclude='*.gem' --directory=.. deep_test"
end
