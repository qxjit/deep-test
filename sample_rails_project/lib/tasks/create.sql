drop database if exists sample_rails_project_development;
drop database if exists sample_rails_project_test;
create database sample_rails_project_development;
create database sample_rails_project_test;
grant all on sample_rails_project_development.* to 'sample_project'@'localhost' identified by 'hello';
grant all on sample_rails_project_test.* to 'sample_project'@'localhost' identified by 'hello';
