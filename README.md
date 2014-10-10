# env-conf

Provides a better way to configure the application than simply pulling
strings from `ENV` by overriding the deprecated `Config` class.

## Features

### defaults

```ruby
Config[:foo]
# => nil

Config.default(:foo, 'bar')
Config[:foo]
# => 'bar'
Config['FOO']
# => 'bar'
```

### type casts

Returns `nil` when undefined, otherwise casts to indicated type.

#### int
```ruby
Config.int(:max_connections)
#=> 10
```



## Installation

Add this line to your application's Gemfile:

```ruby
gem 'env-conf'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install env-conf

## Usage

```ruby
require 'env-conf'

Config[:foo]
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/env-conf/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
