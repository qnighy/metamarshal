# Metamarshal

Have you ever been confronted by a non-loadable marshal data? Metamarshal may help you!

For example, from Rails 4.2 to Rails 5.0, the class `ActionController::Parameters` stopped inheriting `ActiveSupport::HashWithIndifferentAccess` (and `Hash` transitively). This means that if you were using Marshal cookie sessions and you were (perhaps accidentally) saving `ActionController::Parameters` in your session storage, the session may break with undecipherable error message.

Metamarshal is a pure Ruby "parser" for the marshal format. It allows parsing the marshal data without actually trying to realize it as the corresponding Ruby object. Instead, it can output a syntax tree (or a syntax graph in a complex case) so you can modify it before realization.

Metamarshal is totally work-in-progress for now:

- Parsing
  - [x] nil (`0`), true (`T`), false (`F`)
  - [x] Fixnum
  - [ ] Subclasses of String/Regexp/Array/Hash (`C`)
  - [ ] Old user-defined marshal data (`u`)
  - [ ] User-defined marshal data (`U`)
  - [ ] User-defined marshal data for TData (`d`)
  - [x] Plain object (`o`)
  - [ ] Float (`f`)
  - [ ] Bignum (`l`)
  - [ ] String (`"`)
  - [ ] Regexp (`/`)
  - [x] Array (`[`)
  - [ ] Hash without default value (`{`)
  - [ ] Hash with default value (`}`)
  - [ ] Struct (`S`)
  - [ ] Old Class or Module (`M`)
  - [ ] Class (`c`)
  - [ ] Module but not Class (`m`)
  - [x] Symbol (`:`)
    - [ ] encoded symbols
  - [x] Symbol link (`;`)
  - [ ] Extension of an object by a module (`e`)
  - [ ] Instance variables of String/Regexp/Array/Hash (`I`)
  - [x] link (`@`)
- Generation
  - [ ] nil (`0`), true (`T`), false (`F`)
  - [ ] Fixnum
  - [ ] Subclasses of String/Regexp/Array/Hash (`C`)
  - [ ] Old user-defined marshal data (`u`)
  - [ ] User-defined marshal data (`U`)
  - [ ] User-defined marshal data for TData (`d`)
  - [x] Plain object (`o`)
  - [ ] Float (`f`)
  - [ ] Bignum (`l`)
  - [ ] String (`"`)
  - [ ] Regexp (`/`)
  - [ ] Array (`[`)
  - [ ] Hash without default value (`{`)
  - [ ] Hash with default value (`}`)
  - [ ] Struct (`S`)
  - [ ] Old Class or Module (`M`)
  - [ ] Class (`c`)
  - [ ] Module but not Class (`m`)
  - [x] Symbol (`:`)
    - [ ] encoded symbols
  - [x] Symbol link (`;`)
  - [ ] Extension of an object by a module (`e`)
  - [ ] Instance variables of String/Regexp/Array/Hash (`I`)
  - [ ] link (`@`)
- Realization
- Lifting
- Feature
  - [ ] Iterate over parsed objects
  - [ ] Marshal-compatible load/dump interface

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'metamarshal'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install metamarshal

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/qnighy/metamarshal.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
