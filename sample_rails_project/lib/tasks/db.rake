namespace :db do
  task :create do
    create_sql = File.dirname(__FILE__) + "/create.sql"
    system "mysql -u root < #{create_sql}"
  end
  
  task :verbosity => :environment do
    ActiveRecord::Migration.verbose = false
  end
end

Rake::Task['db:migrate'].enhance(['db:create','db:verbosity'])
Rake::Task['db:test:prepare'].enhance(['db:migrate']) do
  ActiveRecord::Base.establish_connection(:test)
  Person.create! :name => "Created In db:test:prepare"
end
