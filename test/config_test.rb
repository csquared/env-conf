require 'helper'

class ConfigTest < Test 
  # Config.env returns the value matching the specified environment
  # variable name.
  def test_env
    ENV['VALUE'] = 'value'
    set_env('VALUE', 'value')
    assert_equal(Config.env('VALUE'), 'value')
    ENV['VALUE'] = nil
  end

  # Config[] returns the value matching the specified environment
  # variable name.
  def test_brackets
    set_env('VALUE', 'value')
    assert_equal(Config[:value], 'value')
    assert_equal(Config['VALUE'], 'value')
  end

  # Config.env return nil if an unknown environment variable is
  # requested.
  def test_env_with_unknown_name
    assert_equal(Config.env('UNKNOWN'), nil)
  end

  # Config.env! returns the value matching the specified environment
  # variable name.
  def test_env!
    set_env('VALUE', 'value')
    assert_equal(Config.env!('VALUE'), 'value')
  end

  # Config.env! raises a RuntimeError if an unknown environment
  # variable is requested.
  def test_env_with_unknown_name!
    error = assert_raises RuntimeError do
      Config.env!('UNKNOWN')
    end
    assert_equal(error.message, 'missing UNKNOWN')
  end

  # Config.production? is true when RACK_ENV=production.
  def test_production_mode
    set_env 'RACK_ENV', nil
    refute Config.production?
    set_env 'RACK_ENV', 'production'
    assert Config.production?
  end

  # Config.development? is true when RACK_ENV=production.
  def test_development_mode
    set_env 'RACK_ENV', nil
    refute Config.development?
    set_env 'RACK_ENV', 'development'
    assert Config.development?
  end

  # Config.test? is true when RACK_ENV=test.
  def test_test_mode
    set_env 'RACK_ENV', nil
    refute Config.test?
    set_env 'RACK_ENV', 'test'
    assert Config.test?
  end

  # Returns DATABASE_URL with no params.
  def test_database_url
    set_env 'DATABASE_URL', "postgres:///foo"
    assert_equal(Config.database_url, 'postgres:///foo')
  end

  # Returns #{kind}_DATABASE_URL with one param
  def test_database_url_takes_and_capitalizes_params
    set_env 'FOO_DATABASE_URL', "postgres:///foo"
    assert_equal(Config.database_url('foo'), 'postgres:///foo')
    assert_equal(Config.database_url(:foo), 'postgres:///foo')
  end

  # Config.database_url raises a RuntimeError if no DATABASE_URL
  # environment variables is defined.
  def test_database_url_raises_when_not_found
    assert_raises RuntimeError do
      Config.database_url('foo')
    end
  end

  # Config.app_name returns the value of the APP_NAME environment
  # variable.
  def test_app_name
    set_env 'APP_NAME', "my-app"
    assert_equal('my-app', Config.app_name)
  end

  # Config.app_deploy returns the value of the APP_DEPLOY environment
  # variable.
  def test_app_deploy
    set_env 'APP_DEPLOY', "test"
    assert_equal('test', Config.app_deploy)
  end

  # Config.port raises a RuntimeError if no `PORT` environment variable
  # is defined.
  def test_port_raises
    assert_raises RuntimeError do
      Config.port
    end
  end

  # Config.port converts the value from the environment to a Fixnum
  def test_port_convert_to_int
    set_env 'PORT', "3000"
    assert_equal(3000, Config.port)
  end

  # Config.int(VAR) returns nil or VAR as integer.
  def test_int
    assert_equal(nil, Config.int('FOO'))
    set_env 'FOO', "3000"
    assert_equal(3000, Config.int('FOO'))
    assert_equal(3000, Config.int(:foo))
    set_env 'FOO', "1.0"
    assert_raises(ArgumentError){ Config.time(:foo) }
    set_env 'FOO', nil
    assert_equal(nil, Config.int(:foo))
    set_env 'FOO', "a"
    assert_raises(ArgumentError){ Config.time(:foo) }
  end

  # Config.time returns nil or VAR as time
  def test_time
    assert_equal(nil, Config.time('T'))
=begin
    set_env 'T', '2000'
    assert_equal(Time.utc(2000), Config.time(:t))
    set_env 'T', '2000-2'
    assert_equal(Time.utc(2000,2), Config.time(:t))
=end
    set_env 'T', '2000-2-2'
    assert_equal(Time.new(2000,2,2), Config.time(:t))

    set_env 'T', '2000-2-2T11:11'
    assert_equal(Time.new(2000,2,2,11,11), Config.time(:t))

    set_env 'T', nil
    assert_equal(nil, Config.time(:t))

    set_env 'T', 'derp'
    assert_raises(ArgumentError){ Config.time(:t) }
  end

  # Config.time returns nil or VAR as URI
  def test_uri
    assert_equal(nil, Config.uri('URL'))
    set_env 'URL', 'http://user:password@the-web.com/path/to/greatness?foo=bar'
    uri = Config.uri('URL')
    assert_equal('http', uri.scheme)
    assert_equal('the-web.com', uri.host)
    assert_equal('/path/to/greatness', uri.path)
    assert_equal('foo=bar', uri.query)
    assert_equal(80, uri.port)
    assert_equal('user', uri.user)
    assert_equal('password', uri.password)
  end

  # Config.array loads a comma-separated list of words into an array of
  # strings.
  def test_array
    set_env 'ARRAY', ''
    assert_equal([], Config.array('ARRAY'))
    set_env 'ARRAY', 'apple'
    assert_equal(['apple'], Config.array('ARRAY'))
    set_env 'ARRAY', 'apple,orange,cherry'
    assert_equal(['apple', 'orange', 'cherry'], Config.array('ARRAY'))
  end

  # Config.bool?(var) is only true if the value of var is the string
  # 'true'.  If the var is absent or any other value, it evaluates to false.
  def test_bool_returns_true
    assert_equal(false, Config.bool?('VAULT_BOOLEAN_VAR'))
    set_env 'VAULT_BOOLEAN_VAR', 'true'
    assert_equal(true, Config.bool?('VAULT_BOOLEAN_VAR'))

    Config.default(:foo, true)
    assert_equal(true, Config.bool?(:foo))
  end

  # Config.bool?(var) is false if the value of var is anything other
  # than the string 'true'.
  def test_bool_returns_false
    set_env 'VAULT_BOOLEAN_VAR', 'false'
    assert_equal(false, Config.bool?('VAULT_BOOLEAN_VAR'))
    set_env 'VAULT_BOOLEAN_VAR', 'foo'
    assert_equal(false, Config.bool?('VAULT_BOOLEAN_VAR'))
    set_env 'VAULT_BOOLEAN_VAR', '1'
    assert_equal(false, Config.bool?('VAULT_BOOLEAN_VAR'))

    Config.default(:foo, false)
    assert_equal(false, Config.bool?(:foo))
  end
  
  def test_app_env
    set_env 'RACK_ENV', nil
    assert_raises RuntimeError do
      Config.app_env
    end
    set_env 'RACK_ENV', 'test'
    assert_equal(:test, Config.app_env)
    set_env 'RACK_ENV', 'development'
    assert_equal(:development, Config.app_env)
    set_env 'RACK_ENV', 'production'
    assert_equal(:production, Config.app_env)
  end
end
