require File.dirname(__FILE__) + '/../vendor/gems/deep_test/lib/deep_test'

class ForeignHostWorkerSimulationListener < DeepTest::NullWorkerListener
  def starting(worker)
    # On a foreign host, there won't necessarily be a database for tests
    # to run against.  We simulate that by dropping them here.
    #
    # It's important that this happens as the first thing when the workers
    # are started, since this is the first listener event that would be
    # invoked on a foreign host.  before_starting_workers would be invoked
    # on the local host, which should have databases available as usual.
    #
    system "mysqladmin -u root -f drop sample_rails_project_development > /dev/null"
    system "mysqladmin -u root -f drop sample_rails_project_test > /dev/null"
  end
end
