module DeepTest
  module Database
    #
    # SetupListener implementation for MySQL.
    #
    class MysqlSetupListener < SetupListener
      class <<self
        #
        # ActiveRecord configuration to use when connecting to
        # MySQL to create databases, drop database, and grant
        # privileges.  By default, connects to information_schema
        # on localhost as root with no password.
        #
        attr_accessor :admin_configuration
      end
      self.admin_configuration = {
        :adapter  => "mysql",
        :host     => "localhost",
        :username => "root",
        :database => "information_schema"
      }

      #
      # Creates database and grants privileges (via +grant_privileges+)
      # on it via ActiveRecord connection based on admin_configuration.
      #
      def create_database
        admin_connection do |connection|
          connection.create_database worker_database
          grant_privileges connection
        end
      end

      #
      # Grants 'all' privilege on worker database to username and password
      # specified by worker database config.  If your application has
      # special database privilege needs beyond 'all', you should override
      # this method and grant them.
      #
      def grant_privileges(connection)
        sql = ActiveRecord::Base.send(:sanitize_sql, [
          %{grant all on #{worker_database}.* 
            to :username@'localhost' identified by :password;}, 
          worker_database_config
        ])
        connection.execute sql
      end

      #
      # Drops database via ActiveRecord connection based on admin_configuration
      #
      def drop_database
        admin_connection do |connection|
          connection.drop_database worker_database
        end
      end

      #
      # Dumps schema from master database using mysqldump command
      #
      def dump_schema
        config = command_line_config(master_database_config)
        system "mysqldump -R #{config} > #{dump_file_name}"
        raise "Error Dumping schema" unless $?.success?
      end

      #
      # Loads dumpfile into worker database using mysql command
      #
      def load_schema
        config = command_line_config(worker_database_config)
        system "mysql #{config} < #{dump_file_name}"
        raise "Error Loading schema" unless $?.success?
      end

      #
      # Location to store dumpfile.  The default assumes you are testing
      # a Rails project.  You should override this if you are not using Rails
      # or would like the dump file to be something other than the default
      #
      def dump_file_name
        "#{RAILS_ROOT}/db/deep_test_schema.sql"
      end

      def system(command) # :nodoc:
        DeepTest.logger.info command
        super command
      end

      def command_line_config(config) # :nodoc:
        command =  ['-u', config[:username]]
        command += ["-p#{config[:password]}"] if config[:password]
        command += ['-h', config[:host]] if config[:host]
        command += ['-P', config[:port]] if config[:port]
        command += ['-S', config[:socket]] if config[:socket]
        command += [config[:database]]
        command.join(' ') 
      end

      def admin_connection # :nodoc:
        conn = ActiveRecord::Base.mysql_connection(self.class.admin_configuration)
        yield conn
      ensure
        conn.disconnect! if conn
      end
    end
  end
end

