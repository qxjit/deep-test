require File.dirname(__FILE__) + "/../../test_helper"

unit_tests do
  test "expects to receive password or authenticity prompt" do
    prompt = "Are you sure you want to continue connecting (yes/no)?"
    rexpect = mock
    rexpect.expects(:expect).with(/Password:|#{Regexp.quote(prompt)}/, 30)
    DeepTest::Distributed::SSHLogin.login("the_password", rexpect)
  end

  test "returns gracefully if no prompt is found within timeout" do
    rexpect = mock
    rexpect.expects(:expect).raises(Timeout::Error.new("timeout"))
    DeepTest::Distributed::SSHLogin.login("the_password", rexpect)
  end

  test "returns gracefully if no end of file is reached" do
    rexpect = mock
    rexpect.expects(:expect).raises(EOFError.new("eof"))
    DeepTest::Distributed::SSHLogin.login("the_password", rexpect)
  end

  test "responds to password prompt with password" do
    rexpect = mock
    rexpect.expects(:expect).times(2).returns(["Password:"]).then.returns(nil)
    rexpect.expects(:puts).with("the_password")
    DeepTest::Distributed::SSHLogin.login("the_password", rexpect)
  end

  test "doesn't use password if password prompt doesn't appear" do
    rexpect = mock
    rexpect.expects(:expect).returns(nil)
    DeepTest::Distributed::SSHLogin.login("the_password", rexpect)
  end

  test "responds to host authenicity error with yes" do
    prompt = "Are you sure you want to continue connecting (yes/no)?"
    rexpect = mock
    rexpect.expects(:expect).times(2).returns([prompt]).then.returns(nil)
    rexpect.expects(:puts).with("yes")
    DeepTest::Distributed::SSHLogin.login("the_password", rexpect)
  end

  test "responds to authenticity error and password prompt in sequence" do
    prompt = "Are you sure you want to continue connecting (yes/no)?"
    rexpect = mock
    rexpect.expects(:expect).times(3).
      returns([prompt]).then.
      returns(["Password:"]).then.
      returns(nil)
    rexpect.expects(:puts).with("yes")
    rexpect.expects(:puts).with("the_password")
    DeepTest::Distributed::SSHLogin.login("the_password", rexpect)
  end

  test "system runs command with open and feeds io to login" do
    RExpect.expects(:spawn).with("command").yields(rexpect = mock)
    DeepTest::Distributed::SSHLogin.expects(:login).with("password", rexpect)
    DeepTest::Distributed::SSHLogin.system("password", "command")
  end

  test "system returns true if command was successful" do
    RExpect.expects(:spawn).with("command")
    $?.expects(:nil?).returns(false)
    $?.expects(:success?).returns(true)
    assert_equal true,
                 DeepTest::Distributed::SSHLogin.system("password", "command")
  end

  test "system returns false if no status is available" do
    RExpect.expects(:spawn).with("command")
    $?.expects(:nil?).returns(true)
    assert_equal false,
                 DeepTest::Distributed::SSHLogin.system("password", "command")
  end
end
