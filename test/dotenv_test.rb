require 'helper'

class DotenvTest < Test 
  def setup
    super
    FakeFS.activate!
  end

  def teardown
    super
    %w{.env .env.local .env.test .env.test.local}.each do |f|
      File.unlink(f) if File.exists?(f)
    end
    FakeFS.deactivate!
  end

  def test_one_var
    File.open(".env",'w') { |f| f << "FOO=bar" }
    assert_equal(nil, Config[:foo])
    Config.dotenv!
    assert_equal('bar', Config[:foo])
  end
  
  def test_two_files
    File.open(".env",'w') { |f| f << "FOO=bar" }
    File.open(".env.local",'w') { |f| f << "FOO=zzz" }
    assert_equal(nil, Config[:foo])
    Config.dotenv!
    assert_equal('zzz', Config[:foo])
  end

  def test_env_specific
    File.open(".env",'w') { |f| f << "FOO=bar" }
    File.open(".env.local",'w') { |f| f << "FOO=zzz" }
    File.open(".env.test",'w') { |f| f << "FOO=foo" }
    File.open(".env.test.local",'w') { |f| f << "FOO=test" }
    assert_equal(nil, Config[:foo])
    set_env('RACK_ENV', 'test')
    Config.dotenv!
    assert_equal('test', Config[:foo])
  end

  def test_noop_in_prod
    File.open(".env",'w') { |f| f << "FOO=bar" }
    File.open(".env.local",'w') { |f| f << "FOO=zzz" }
    File.open(".env.test",'w') { |f| f << "FOO=test" }
    assert_equal(nil, Config[:foo])
    set_env('RACK_ENV', 'production')
    Config.dotenv!
    assert_equal(nil, Config[:foo])
  end
end
