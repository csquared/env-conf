# Unset Ruby's deprecated Config class to make room for ours
Object.send(:remove_const, :Config) if defined?(Config)

module Config
  VERSION = '0.0.1'
end
