cashrb
======

Dead simple gem to work with Money/Currency without the hassle of Floats.

Usage
-----

    require 'cash'

    # Works with cents to avoid Floating point errors
    n = Cash.new(100)
    n.cents #=> 100
    n.to_s  #=> "1.00"
    n.to_f  #=> 1.0

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
