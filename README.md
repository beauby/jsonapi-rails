# jsonapi-rails
Ruby gem for parsing [JSON API](http://jsonapi.org) documents for ActiveRecord.

## Installation

Add the following to your application's Gemfile:
```ruby
gem 'jsonapi-rails'
```
And then execute:
```
$ bundle
```
Or install it manually as:
```
$ gem install jsonapi-rails
```

## Usage

First, `require` the gem.
```ruby
require 'jsonapi'
```

Then, parse a JSON API document:

```ruby
hash = JSONAPI::Deserializable.to_active_record_hash(json_api_params, options: {}, klass: nil)
```

Notes
 - that klass is optional, and defaults to nil, but will infer the type from the json api document.
 - this will not do any key transforms -- casing will be consistent from input to output
 - this does not perform validations. (see jsonapi/validations)


### Available Options

 - polymorphic

## Examples

```ruby

```

## Contributing

1. Fork the [official repository](https://github.com/beauby/jsonapi-rails/tree/master).
2. Make your changes in a topic branch.
3. Send a pull request.

Notes:

* Contributions without tests won't be accepted.
* Please don't update the Gem version.

## License

It is free software, and may be redistributed under the terms specified in the
[LICENSE](LICENSE) file.
