require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rake/gempackagetask'
require 'rake/contrib/sshpublisher'
require 'yaml'
$LOAD_PATH << File.dirname(__FILE__) + "/lib"
gem('rspec', ENV['RSPEC_VERSION']) if ENV['RSPEC_VERSION']

require "deep_test/rake_tasks"

task :default => %w[
  test 
  spec 
  deep_test
  deep_spec_1.1.8
  deep_spec_1.1.12
  distributed_test
  distributed_spec
  negative_acceptance_tests
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
    t.deep_test({})
  end

  task :'deep_spec_1.1.8' do 
    sh 'rake deep_spec RSPEC_VERSION=1.1.8'
  end

  task :'deep_spec_1.1.12' do
    sh 'rake deep_spec RSPEC_VERSION=1.1.12'
  end

  Spec::Rake::SpecTask.new(:distributed_spec) do |t|
    t.spec_files = FileList['spec/**/*_spec.rb']
    t.deep_test :distributed_hosts => %w[localhost],
                :sync_options => {:source => File.dirname(__FILE__), 
                                  :rsync_options => "--exclude=.svn"}
  end
end

Rake::TestTask.new(:negative_acceptance_tests) do |t|
  t.pattern = "negative_acceptance_tests/tests.rb"
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
    'lib/deep_test/null_listener.rb',
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

  s.has_rdoc = true
  s.extra_rdoc_files = ['README.rdoc', 'CHANGELOG']
  s.rdoc_options << '--title' << "DeepTest" << '--main' << 'README.rdoc' << '--line-numbers'

  s.files = FileList['{lib,test}/**/*.{rb,rake}', 'README.rdoc', 'CHANGELOG', 'Rakefile'].to_a
end

Rake::GemPackageTask.new(specification) do |package|
  package.need_zip = true
  package.need_tar = true
end

Rake::Task[:gem].prerequisites.unshift :default

task :tar do
  system "tar zcf pkg/deep_test.tar.gz --exclude=.svn --exclude='*.tar.gz' --exclude='*.gem' --directory=.. deep_test"
end
