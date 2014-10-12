# Taxing

Calculate income tax on Australian gross taxable income.

This is a work in progress, currently it only calculates income tax without regard to rebates, offsets, super etc, however these are planned for the future.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'taxing'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install taxing

## Usage

```ruby
require 'taxing'
calculator = ::Taxing::IncomeTaxCalculator.new(2015)
tax = calculator.calculate('155000.00')
puts "Income tax is $#{'%.2f' % tax}"
Income tax is $45297.00
```

## Running the tests

    $ rake spec

## Contributing

1. Fork it ( https://github.com/[my-github-username]/taxing/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
