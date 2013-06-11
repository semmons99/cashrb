require 'minitest/autorun'
require 'bigdecimal'
require 'cashrb/cash'

class TestCash < MiniTest::Unit::TestCase

  def teardown
    Cash.reset_defaults
  end

  def test_default_cents_in_whole
    Cash.default_cents_in_whole = 10

    rs = Cash.new(100)
    assert_equal "10.0", rs.to_s
  end

  def test_pence_aliases_cents
    rs = Cash.new(100)
    assert_equal rs.cents, rs.pence
  end

  def test_default_rounding_method
    Cash.default_rounding_method = BigDecimal::ROUND_DOWN

    rs = Cash.new(1.9)
    assert_equal 1, rs.cents
  end

  def test_default_currency
    Cash.default_currency = :usd

    rs = Cash.new(100)
    assert_equal :usd, rs.currency
  end

  def test_default_from
    Cash.default_from = :decimal

    rs = Cash.new(1.11)
    assert_equal 111, rs.cents
  end

  def test_invalid_default_from
    assert_raises ArgumentError do
      Cash.default_from = :foo
    end
  end

  def test_new
    rs = Cash.new(100)
    assert_equal 100, rs.cents
    assert_equal nil, rs.currency
  end

  def test_new_with_default_rounding_method
    rs = Cash.new(2.5)
    assert_equal 3, rs.cents
  end

  def test_new_with_rounding_method
    rs = Cash.new(2.5, :rounding_method => BigDecimal::ROUND_HALF_EVEN)
    assert_equal 2, rs.cents
  end

  def test_new_with_currency
    rs = Cash.new(0, :currency => :usd)
    assert_equal :usd, rs.currency
  end

  def test_new_with_currency_respond_to_cents_in_whole
    currency = MiniTest::Mock.new
    currency.expect(:cents_in_whole, 10)

    rs = Cash.new(9, :currency => currency)
    assert_equal 0.9, rs.to_f
  end

  def test_new_with_from
    rs = Cash.new(111, :from => :cents)
    assert_equal 111, rs.cents

    rs = Cash.new(1.11, :from => :decimal)
    assert_equal 111, rs.cents
  end

  def test_new_with_from_and_cents_in_whole
    rs = Cash.new(111, :from => :cents, :cents_in_whole => 1)
    assert_equal 111, rs.cents

    rs = Cash.new(111, :from => :cents, :cents_in_whole => 5)
    assert_equal 111, rs.cents

    rs = Cash.new(111, :from => :cents, :cents_in_whole => 10)
    assert_equal 111, rs.cents

    rs = Cash.new(111, :from => :cents, :cents_in_whole => 100)
    assert_equal 111, rs.cents

    rs = Cash.new(111, :from => :cents, :cents_in_whole => 1000)
    assert_equal 111, rs.cents

    rs = Cash.new(1.0, :from => :decimal, :cents_in_whole => 1)
    assert_equal 1, rs.cents

    rs = Cash.new(1.1, :from => :decimal, :cents_in_whole => 5)
    assert_equal 6, rs.cents

    rs = Cash.new(1.1, :from => :decimal, :cents_in_whole => 10)
    assert_equal 11, rs.cents

    rs = Cash.new(1.11, :from => :decimal, :cents_in_whole => 100)
    assert_equal 111, rs.cents

    rs = Cash.new(1.01, :from => :decimal, :cents_in_whole => 100)
    assert_equal 101, rs.cents

    rs = Cash.new(1.00, :from => :decimal, :cents_in_whole => 100)
    assert_equal 100, rs.cents

    rs = Cash.new(1.111, :from => :decimal, :cents_in_whole => 1000)
    assert_equal 1111, rs.cents

    rs = Cash.new(1.011, :from => :decimal, :cents_in_whole => 1000)
    assert_equal 1011, rs.cents

    rs = Cash.new(1.001, :from => :decimal, :cents_in_whole => 1000)
    assert_equal 1001, rs.cents

    rs = Cash.new(1.000, :from => :decimal, :cents_in_whole => 1000)
    assert_equal 1000, rs.cents
  end

  def test_new_with_invalid_from
    assert_raises ArgumentError do
      Cash.new(1, :from => :foo)
    end
  end

  def test_plus_with_Cash_Cash
    rs = Cash.new(6) + Cash.new(4)
    assert_equal Cash.new(10), rs
  end

  def test_plus_with_Cash_Cash_with_different_currencies
    assert_raises Cash::IncompatibleCurrency do
      Cash.new(6) + Cash.new(4, :currency => :usd)
    end
  end

  def test_plus_with_modified_defaults
    Cash.default_cents_in_whole  = 10
    Cash.default_rounding_method = BigDecimal::ROUND_UP
    Cash.default_currency        = :usd
    Cash.default_from            = :decimal

    rs = Cash.new(10) + Cash.new(5)
    assert_equal Cash.new(15), rs
  end

  def test_minus_with_Cash_Cash
    rs = Cash.new(6) - Cash.new(4)
    assert_equal Cash.new(2), rs
  end

  def test_minus_with_Cash_Cash_with_different_currencies
    assert_raises Cash::IncompatibleCurrency do
      Cash.new(6) - Cash.new(4, :currency => :usd)
    end
  end

  def test_minus_with_modified_defaults
    Cash.default_cents_in_whole  = 10
    Cash.default_rounding_method = BigDecimal::ROUND_UP
    Cash.default_currency        = :usd
    Cash.default_from            = :decimal

    rs = Cash.new(10) - Cash.new(5)
    assert_equal Cash.new(5), rs
  end

  def test_unary_minus
    rs = -Cash.new(6)
    assert_equal Cash.new(-6), rs
  end

  def test_unary_minus_with_modified_defaults
    Cash.default_cents_in_whole  = 10
    Cash.default_rounding_method = BigDecimal::ROUND_UP
    Cash.default_currency        = :usd
    Cash.default_from            = :decimal

    rs = -Cash.new(6)
    assert_equal Cash.new(-6), rs
  end

  def test_multiply_with_Cash_Numeric
    rs = Cash.new(6) * 2
    assert_equal Cash.new(12), rs
  end

  def test_multiply_with_modified_defaults
    Cash.default_cents_in_whole  = 10
    Cash.default_rounding_method = BigDecimal::ROUND_UP
    Cash.default_currency        = :usd
    Cash.default_from            = :decimal

    rs = Cash.new(10) * 5
    assert_equal Cash.new(50), rs
  end

  def test_divide_with_Cash_Cash
    rs = Cash.new(6) / Cash.new(4)
    assert_equal BigDecimal("1.5"), rs
  end

  def test_divide_with_Cash_Cash_with_different_currencies
    assert_raises Cash::IncompatibleCurrency do
      Cash.new(6) / Cash.new(4, :currency => :usd)
    end
  end

  def test_divide_with_Cash_Numeric
    rs = Cash.new(6) / 2
    assert_equal Cash.new(3), rs
  end

  def test_divide_with_modified_defaults
    Cash.default_cents_in_whole  = 10
    Cash.default_rounding_method = BigDecimal::ROUND_UP
    Cash.default_currency        = :usd
    Cash.default_from            = :decimal

    rs = Cash.new(10) / 5
    assert_equal Cash.new(2), rs
  end

  def test_modulo_with_Cash_Cash
    rs = Cash.new(6) % Cash.new(4)
    assert_equal Cash.new(2), rs
  end

  def test_modulo_with_Cash_Cash_with_different_currencies
    assert_raises Cash::IncompatibleCurrency do
      Cash.new(6) % Cash.new(4, :currency => :usd)
    end
  end
      
  def test_modulo_with_Cash_Numeric
    rs = Cash.new(6) % 4
    assert_equal Cash.new(2), rs
  end

  def test_modulo_with_modified_defaults
    Cash.default_cents_in_whole  = 10
    Cash.default_rounding_method = BigDecimal::ROUND_UP
    Cash.default_currency        = :usd
    Cash.default_from            = :decimal

    rs = Cash.new(6) % 7
    assert_equal Cash.new(0.4), rs
  end

  def test_divmod_with_Cash_Cash
    rs = Cash.new(6).divmod(Cash.new(4))
    assert_equal [BigDecimal("1"), Cash.new(2)], rs
  end

  def test_divmod_with_Cash_Cash_with_different_currencies
    assert_raises Cash::IncompatibleCurrency do
      Cash.new(6).divmod(Cash.new(4, :currency => :usd))
    end
  end

  def test_divmod_with_Cash_Numeric
    rs = Cash.new(6).divmod(4)
    assert_equal [Cash.new(1), Cash.new(2)], rs
  end

  def test_divmod_with_modified_defaults
    Cash.default_cents_in_whole  = 10
    Cash.default_rounding_method = BigDecimal::ROUND_UP
    Cash.default_currency        = :usd
    Cash.default_from            = :decimal

    rs = Cash.new(6).divmod(40)
    assert_equal [Cash.new(0.1), Cash.new(2)], rs
  end

  def test_abs_with_positive_cents
    assert_equal Cash.new(120), Cash.new(120).abs
  end

  def test_abs_with_negative_cents
    assert_equal Cash.new(120), Cash.new(-120).abs
  end

  def test_equal_to_when_equal_to
    rs = Cash.new(6) == Cash.new(6)
    assert rs
  end

  def test_equal_to_when_not_equal_to
    rs = Cash.new(6) == Cash.new(4)
    refute rs
  end

  def test_equal_to_with_different_currencies
    rs = Cash.new(6) == Cash.new(6, :currency => :usd)
    refute rs
  end

  def test_compare_when_greater_than
    rs = Cash.new(6) <=> Cash.new(4)
    assert_equal 1, rs
  end

  def test_compare_when_less_than
    rs = Cash.new(4) <=> Cash.new(6)
    assert_equal -1, rs
  end

  def test_compare_when_equal_to
    rs = Cash.new(6) <=> Cash.new(6)
    assert_equal 0, rs
  end

  def test_compare_with_different_currencies
    assert_raises Cash::IncompatibleCurrency do
      Cash.new(6) <=> Cash.new(6, :currency => :usd)
    end
  end

  def test_greater_than_when_greater_than
    rs = Cash.new(6) > Cash.new(4)
    assert rs
  end

  def test_greater_than_when_less_than
    rs = Cash.new(4) > Cash.new(6)
    refute rs
  end

  def test_greater_than_when_equal_to
    rs = Cash.new(6) > Cash.new(6)
    refute rs
  end

  def test_greater_than_with_different_currencies
    assert_raises Cash::IncompatibleCurrency do
      Cash.new(6) > Cash.new(6, :currency => :usd)
    end
  end

  def test_less_than_when_greater_than
    rs = Cash.new(6) < Cash.new(4)
    refute rs
  end

  def test_less_than_when_less_than
    rs = Cash.new(4) < Cash.new(6)
    assert rs
  end

  def test_less_than_when_equal_to
    rs = Cash.new(6) < Cash.new(6)
    refute rs
  end

  def test_less_than_with_different_currencies
    assert_raises Cash::IncompatibleCurrency do
      Cash.new(6) < Cash.new(6, :currency => :usd)
    end
  end

  def test_greater_than_or_equal_to_when_greater_than
    rs = Cash.new(6) >= Cash.new(4)
    assert rs
  end

  def test_greater_than_or_equal_to_when_less_than
    rs = Cash.new(4) >= Cash.new(6)
    refute rs
  end

  def test_greater_than_or_equal_to_when_equal_to
    rs = Cash.new(6) >= Cash.new(6)
    assert rs
  end

  def test_greater_than_or_equal_to_with_different_currencies
    assert_raises Cash::IncompatibleCurrency do
      Cash.new(6) >= Cash.new(6, :currency => :usd)
    end
  end

  def test_less_than_or_equal_to_when_greater_than
    rs = Cash.new(6) <= Cash.new(4)
    refute rs
  end

  def test_less_than_or_equal_to_when_less_than
    rs = Cash.new(4) <= Cash.new(6)
    assert rs
  end

  def test_less_than_or_equal_to_when_equal_to
    rs = Cash.new(6) <= Cash.new(6)
    assert rs
  end

  def test_less_than_or_equal_to_with_different_currencies
    assert_raises Cash::IncompatibleCurrency do
      Cash.new(6) <= Cash.new(6, :currency => :usd)
    end
  end
    
  def test_to_s
    assert_equal "0.00", Cash.new(0  ).to_s
    assert_equal "0.01", Cash.new(1  ).to_s
    assert_equal "0.10", Cash.new(10 ).to_s
    assert_equal "1.00", Cash.new(100).to_s
    assert_equal "1.01", Cash.new(101).to_s
    assert_equal "1.10", Cash.new(110).to_s
  end

  def test_to_s_with_cents_in_whole
    assert_equal "0",     Cash.new(0,    :cents_in_whole => 1   ).to_s
    assert_equal "1",     Cash.new(1,    :cents_in_whole => 1   ).to_s
    assert_equal "0.4",   Cash.new(4,    :cents_in_whole => 5   ).to_s
    assert_equal "1.0",   Cash.new(5,    :cents_in_whole => 5   ).to_s
    assert_equal "0.9",   Cash.new(9,    :cents_in_whole => 10  ).to_s
    assert_equal "1.0",   Cash.new(10,   :cents_in_whole => 10  ).to_s
    assert_equal "0.99",  Cash.new(99,   :cents_in_whole => 100 ).to_s
    assert_equal "1.00",  Cash.new(100,  :cents_in_whole => 100 ).to_s
    assert_equal "0.999", Cash.new(999,  :cents_in_whole => 1000).to_s
    assert_equal "1.000", Cash.new(1000, :cents_in_whole => 1000).to_s
  end

  def test_to_s_with_negative_cents
    assert_equal "-6338.33", Cash.new(-633833).to_s
  end

  def test_to_f
    assert_equal 0.0,  Cash.new(0  ).to_f
    assert_equal 0.01, Cash.new(1  ).to_f
    assert_equal 0.1,  Cash.new(10 ).to_f
    assert_equal 1.0,  Cash.new(100).to_f
    assert_equal 1.01, Cash.new(101).to_f
    assert_equal 1.1,  Cash.new(110).to_f
  end

  def test_to_f_with_cents_in_whole
    assert_equal 0.0,   Cash.new(0,    :cents_in_whole => 1   ).to_f
    assert_equal 1.0,   Cash.new(1,    :cents_in_whole => 1   ).to_f
    assert_equal 0.4,   Cash.new(4,    :cents_in_whole => 5   ).to_f
    assert_equal 1.0,   Cash.new(5,    :cents_in_whole => 5   ).to_f
    assert_equal 0.9,   Cash.new(9,    :cents_in_whole => 10  ).to_f
    assert_equal 1.0,   Cash.new(10,   :cents_in_whole => 10  ).to_f
    assert_equal 0.99,  Cash.new(99,   :cents_in_whole => 100 ).to_f
    assert_equal 1.0,   Cash.new(100,  :cents_in_whole => 100 ).to_f
    assert_equal 0.999, Cash.new(999,  :cents_in_whole => 1000).to_f
    assert_equal 1.0,   Cash.new(1000, :cents_in_whole => 1000).to_f
  end

  def test_to_f_with_negative_cents
    assert_equal -6338.33, Cash.new(-633833).to_f
  end

  # VAT related tests

  def test_default_vat
    Cash.default_vat = 25
    rs = Cash.new(100)
    assert_equal rs.cents_plus_vat, 125
    assert_equal rs.pence_plus_vat, 125
  end

  def test_new_with_vat
    rs = Cash.new(100, :vat => 17.5)
    assert_equal rs.cents_plus_vat, 117.5
  end

  def test_default_vat_included
    Cash.default_vat_included = :true
    rs = Cash.new(120)
    assert_equal rs.vat_included?, true
  end

  def test_cent_plus_vat_with_vat_included
    rs = Cash.new(120, :vat_included => :true)
    assert_equal rs.cents_plus_vat, rs.cents
  end
  def test_cent_less_vat_with_vat_included
    rs = Cash.new(120, :vat_included => :true)
    assert_equal rs.cents_less_vat, BigDecimal.new(100)
  end
  def test_cent_less_vat_without_vat_included
    rs = Cash.new(120)
    assert_equal rs.cents_less_vat, rs.cents
  end
  def test_mixed_vat_values
    with_vat = ->{ Cash.new(100, :vat_included => :true) }.call
    without_vat = ->{ Cash.new(100, :vat_included => :false) }.call
    addition = with_vat + without_vat
    refute addition.vat_included?, 'vat seems to be included'
    assert addition.vat_mixed?, 'vat should be mixed'
  end
end
