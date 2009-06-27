module DeepTest
  module Database
    #
    # Skeleton Listener to help with setting up a separate database
    # for each worker.  Calls +dump_schema+, +load_schema+, +create_database+,
    # and +drop_database+ hooks provided by subclasses that implement database
    # setup strategies for particular database flavors.
    #
    class SetupListener < NullListener
      DUMPED_SCHEMAS = [] unless defined?(DUMPED_SCHEMAS)

      def before_sync # :nodoc:
        dump_schema_once
      end

      def before_starting_workers # :nodoc:
        dump_schema_once
      end

      def dump_schema_once # :nodoc:
        schema_name = master_database_config[:database]
        dump_schema unless DUMPED_SCHEMAS.include?(schema_name)
        DUMPED_SCHEMAS << schema_name
      end

      def starting(worker) # :nodoc:
        @worker = worker

        at_exit do
          DeepTest.logger.debug { "dropping database #{worker_database}" }
          drop_database
        end

        drop_database
        create_database
        connect_to_database
        load_schema
      end

      #
      # Called on each worker after creating database and before loading
      # schema to initialize connections
      # 
      def connect_to_database
        ActiveRecord::Base.establish_connection(worker_database_config)
      end

      #
      # Called in each worker to create the database named by 
      # +worker_database+.
      #
      def create_database
        raise "Subclass must implement"
      end

      #
      # Called in each worker to drop the database created by
      # +create_database+.  This method is called twice, once before
      # +create_database+ to ensure that no database exists and once
      # at exit to clean as the worker process exits.  This method
      # must not fail if the database does not exist when it is called.
      #
      def drop_database
        raise "Subclass must implement"
      end

      #
      # Called before any workers are spawned to dump the schema that
      # will be used for testing.  When running distributed, this method
      # is called on the local machine providing the tests to run.
      #
      # For distributed testing to work, the schema must be dumped in
      # location accessible by all worker machines.  The easiest way to
      # accomplish this is to dump it to a location within the working copy.
      #
      def dump_schema
        raise "Subclass must implement"
      end


      #
      # Called once in each worker as it is starting to load the schema
      # dumped from dump_schema.  Subclasses should load the schema definition
      # into the +worker_database+
      #
      def load_schema
        raise "Subclass must implement"
      end

      #
      # ActiveRecord configuration for the worker database.  By default,
      # the same as +master_database_config+, except that points to
      # +worker_database+ instead of the database named in the master config.
      # 
      def worker_database_config
        master_database_config.merge(:database => worker_database)
      end

      #
      # ActiveRecord configuration for the master database, based on
      # RAILS_ENV.  If not running Rails, you'll need to override this
      # to provide the correct configuration.
      #
      def master_database_config
        ActiveRecord::Base.configurations[RAILS_ENV].with_indifferent_access
      end

      #
      # Unique name for database on machine that worker is running on.
      #
      def worker_database
        "deep_test_worker_#{@worker.number}_pid_#{Process.pid}" 
      end
    end
  end
end
