require 'minitest'
require 'minitest/autorun'
require 'minitest/pride'
require 'fakefs/safe'

require 'env-conf'

module EnvironmentHelpers
  # Override an environment variable in the current test.
  def set_env(key, value)
    @overrides[key] = ENV[key] unless @overrides.has_key?(key)
    ENV[key] = value
  end

  def setup
    super
    @overrides = {}
  end

  # Restore the environment back to its state before tests ran.
  def teardown
    @overrides.each { |key, value| ENV[key] = value }
    super
  end
end

class Test < Minitest::Test
  include EnvironmentHelpers

  def teardown
    super
    Config.reset!
  end
end

