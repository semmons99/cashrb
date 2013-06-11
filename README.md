cashrb
======

Lightweight money and currency handler for working with financial calculations.
Ensures precision without sacrificing speed. Eschews complexity by only
providing what you need to get your job done.

Usage
-----

```ruby
require 'cashrb'

# Works with cents to avoid Floating point errors. (You can use `cents` or `pence` interchangeably)
n = Cash.new(100)
n.cents #=> 100
n.pence #=> 100
n.to_s  #=> "1.00"
n.to_f  #=> 1.0

# Don't like passing cents, set :from => :decimal and use a decimal value
n = Cash.new(1.11, from: :decimal)
n.cents #=> 111
n.to_s  #=> "1.11"
n.to_f  #=> 1.11

# Hate cents and always want to pass a decimal, just set the default
Cash.default_from = :decimal
n = Cash.new(1.11)
n.cents #=> 111

# Define currency as you see fit.
a = Cash.new(100, currency: :usd)
b = Cash.new(100, currency: :eur)
a + b #=> Error! Cash::IncompatibleCurrency

# Default is 100 cents in a dollar. Is your currency different, then just
# tell it.
n = Cash.new(100, cents_in_dollar: 5)
n.cents #=> 100
n.to_s  #=> "20.0"
n.to_f  #=> 20.0

n = Cash.new(100, cents_in_dollar: 10)
n.cents #=> 100
n.to_s  #=> "10.0"
n.to_f  #=> 10.0

n = Cash.new(100, cents_in_dollar: 1)
n.cents #=> 100
n.to_s  #=> "100"
n.to_f  #=> 100.0

# The default rounding method when dealing with fractional cents is
# BigDecimal::ROUND_HALF_UP. Would you rather use bankers rounding; just
# pass it as an argument.
n = Cash.new(2.5)
n.cents #=> 3

n = Cash.new(2.5, rounding_method: BigDecimal::ROUND_HALF_EVEN)
n.cents #=> 2

# Sick of specifying :cents_in_whole, :rounding_method and :currency; just
# set their defaults.
Cash.default_cents_in_whole  = 10
Cash.default_rounding_method = BigDecimal::ROUND_DOWN
Cash.default_currency        = :EUR

n = Cash.new(100)
n.to_s     #=> "10.0"
n.to_f     #=> 10.0
n.currency #=> :EUR

n = Cash.new(1.9)
n.cents #=> 1

# If your currency object implements :cents_in_whole, we'll go ahead and
# use that.

module MyCurrency
  def self.cents_in_whole
    10
  end
end

n = Cash.new(9, :currency => MyCurrency)
n.to_f #=> 0.9

# Convert existing values into Cash objects
100.to_cash #=> Cash.new(100)
100.00.to_cash #=> Cash.new(100.00)
price = BigDecimal.new(100)
price.to_cash #=> Cash.new(price)

# Even works with formatted strings!

'£12,345.67'.to_cash #=> Cash.new(12345.67)

# all options are passed through too

123.45.to_cash(from: :decimal) #=> Cash.new(123.45, from: :decimal)

# VAT options
# Cash objects can track whether they have had VAT applied to them or not, and offer some convenience methods for checking:

n = Cash.new(100)
n.vat_included? #=> false
n.cents_plus_vat #=> 120

# It will return the correct calculation based on it's vat status too:

n.cents_less_vat #=> 100 (It doesn't have vat included, so the cents less vat is the same)

n= Cash.new(120, :vat_included => :true) #pass a symbol as :true, :false or :mixed
n.vat_included? #=> true
n.cents_less_vat #=> 100
n.cents_plus_vat #=> 120 (returns itself, as it already has vat applied)

# VAT defaults to 20%, you can change this globally using:

Cash.default_vat = 15
n = Cash.new(100)
n.cents_plus_vat #=> 115

# VAT is not included by default, but this can be changed

Cash.reset_defaults
n = Cash.new(100)
n.vat_included? #=> false

Cash.default_vat_inclusion = :true
n = Cash.new(100)
n.vat_included? #=> true

# Objects will keep track of their status when added or subtracted from each other

with_vat    = ->{ Cash.new(100, :vat_included => true) }.call
without_vat = ->{ Cash.new(100, :vat_included => false) }.call

two_with_vats       = with_vat + with_vat
two_without_vats    = without_vat + without_vat
mixed_vat_statuses  = with_vat + without_vat

two_with_vats.vat_included? #=> true
two_without_vats.vat_included? #=> false
mixed_vat_statuses.vat_included? #=> false

mixed_vat_statuses.vat_mixed? #=> true

# We've just provided the queries for you to check in your own code. No errors are thrown when vat is calculated on a mixed status cash object.

```
