require 'minitest/autorun'
require 'bigdecimal'
require 'cash'

class TestCash < MiniTest::Unit::TestCase

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
    rs = Cash.new(2.5, rounding_method: BigDecimal::ROUND_HALF_EVEN)
    assert_equal 2, rs.cents
  end

  def test_new_with_currency
    rs = Cash.new(0, currency: :usd)
    assert_equal :usd, rs.currency
  end

  def test_plus_with_Cash_Cash
    rs = Cash.new(6) + Cash.new(4)
    assert_equal Cash.new(10), rs
  end

  def test_plus_with_Cash_Cash_with_different_currencies
    assert_raises Cash::IncompatibleCurrency do
      Cash.new(6) + Cash.new(4, currency: :usd)
    end
  end

  def test_minus_with_Cash_Cash
    rs = Cash.new(6) - Cash.new(4)
    assert_equal Cash.new(2), rs
  end

  def test_minus_with_Cash_Cash_with_different_currencies
    assert_raises Cash::IncompatibleCurrency do
      Cash.new(6) - Cash.new(4, currency: :usd)
    end
  end

  def test_multiple_with_Cash_Numeric
    rs = Cash.new(6) * 2
    assert_equal Cash.new(12), rs
  end

  def test_divide_with_Cash_Cash
    rs = Cash.new(6) / Cash.new(4)
    assert_equal BigDecimal("1.5"), rs
  end

  def test_divide_with_Cash_Cash_with_different_currencies
    assert_raises Cash::IncompatibleCurrency do
      Cash.new(6) / Cash.new(4, currency: :usd)
    end
  end

  def test_divide_with_Cash_Numeric
    rs = Cash.new(6) / 2
    assert_equal Cash.new(3), rs
  end

  def test_modulo_with_Cash_Cash
    rs = Cash.new(6) % Cash.new(4)
    assert_equal Cash.new(2), rs
  end

  def test_modulo_with_Cash_Cash_with_different_currencies
    assert_raises Cash::IncompatibleCurrency do
      Cash.new(6) % Cash.new(4, currency: :usd)
    end
  end
      
  def test_modulo_with_Cash_Numeric
    rs = Cash.new(6) % 4
    assert_equal Cash.new(2), rs
  end

  def test_divmod_with_Cash_Cash
    rs = Cash.new(6).divmod(Cash.new(4))
    assert_equal [BigDecimal("1"), Cash.new(2)], rs
  end

  def test_divmod_with_Cash_Cash_with_different_currencies
    assert_raises Cash::IncompatibleCurrency do
      Cash.new(6).divmod(Cash.new(4, currency: :usd))
    end
  end

  def test_divmod_with_Cash_Numeric
    rs = Cash.new(6).divmod(4)
    assert_equal [Cash.new(1), Cash.new(2)], rs
  end

  def test_equal_to_when_equal_to
    rs = Cash.new(6) == Cash.new(6)
    assert true
  end

  def test_equal_to_when_not_equal_to
    rs = Cash.new(6) == Cash.new(4)
    refute false
  end

  def test_equal_to_with_different_currencies
    assert_raises Cash::IncompatibleCurrency do
      Cash.new(6) == Cash.new(6, currency: :usd)
    end
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
      Cash.new(6) <=> Cash.new(6, currency: :usd)
    end
  end

  def test_greater_than_when_greater_than
    rs = Cash.new(6) > Cash.new(4)
    assert true
  end

  def test_greater_than_when_less_than
    rs = Cash.new(4) > Cash.new(6)
    refute false
  end

  def test_greater_than_when_equal_to
    rs = Cash.new(6) > Cash.new(6)
    refute false
  end

  def test_greater_than_with_different_currencies
    assert_raises Cash::IncompatibleCurrency do
      Cash.new(6) > Cash.new(6, currency: :usd)
    end
  end

  def test_less_than_when_greater_than
    rs = Cash.new(6) < Cash.new(4)
    refute false
  end

  def test_less_than_when_less_than
    rs = Cash.new(4) < Cash.new(6)
    assert true
  end

  def test_less_than_when_equal_to
    rs = Cash.new(6) < Cash.new(6)
    refute false
  end

  def test_less_than_with_different_currencies
    assert_raises Cash::IncompatibleCurrency do
      Cash.new(6) < Cash.new(6, currency: :usd)
    end
  end

  def test_greater_than_or_equal_to_when_greater_than
    rs = Cash.new(6) >= Cash.new(4)
    assert true
  end

  def test_greater_than_or_equal_to_when_less_than
    rs = Cash.new(4) >= Cash.new(6)
    refute false
  end

  def test_greater_than_or_equal_to_when_equal_to
    rs = Cash.new(6) >= Cash.new(6)
    assert true
  end

  def test_greater_than_or_equal_to_with_different_currencies
    assert_raises Cash::IncompatibleCurrency do
      Cash.new(6) >= Cash.new(6, currency: :usd)
    end
  end

  def test_less_than_or_equal_to_when_greater_than
    rs = Cash.new(6) <= Cash.new(4)
    refute false
  end

  def test_less_than_or_equal_to_when_less_than
    rs = Cash.new(4) <= Cash.new(6)
    assert true
  end

  def test_less_than_or_equal_to_when_equal_to
    rs = Cash.new(6) <= Cash.new(6)
    assert true
  end

  def test_less_than_or_equal_to_with_different_currencies
    assert_raises Cash::IncompatibleCurrency do
      Cash.new(6) <= Cash.new(6, currency: :usd)
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
    assert_equal "0",     Cash.new(0,    cents_in_whole: 1   ).to_s
    assert_equal "1",     Cash.new(1,    cents_in_whole: 1   ).to_s
    assert_equal "0.4",   Cash.new(4,    cents_in_whole: 5   ).to_s
    assert_equal "1.0",   Cash.new(5,    cents_in_whole: 5   ).to_s
    assert_equal "0.9",   Cash.new(9,    cents_in_whole: 10  ).to_s
    assert_equal "1.0",   Cash.new(10,   cents_in_whole: 10  ).to_s
    assert_equal "0.99",  Cash.new(99,   cents_in_whole: 100 ).to_s
    assert_equal "1.00",  Cash.new(100,  cents_in_whole: 100 ).to_s
    assert_equal "0.999", Cash.new(999,  cents_in_whole: 1000).to_s
    assert_equal "1.000", Cash.new(1000, cents_in_whole: 1000).to_s
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
    assert_equal 0.0,   Cash.new(0,    cents_in_whole: 1   ).to_f
    assert_equal 1.0,   Cash.new(1,    cents_in_whole: 1   ).to_f
    assert_equal 0.4,   Cash.new(4,    cents_in_whole: 5   ).to_f
    assert_equal 1.0,   Cash.new(5,    cents_in_whole: 5   ).to_f
    assert_equal 0.9,   Cash.new(9,    cents_in_whole: 10  ).to_f
    assert_equal 1.0,   Cash.new(10,   cents_in_whole: 10  ).to_f
    assert_equal 0.99,  Cash.new(99,   cents_in_whole: 100 ).to_f
    assert_equal 1.0,   Cash.new(100,  cents_in_whole: 100 ).to_f
    assert_equal 0.999, Cash.new(999,  cents_in_whole: 1000).to_f
    assert_equal 1.0,   Cash.new(1000, cents_in_whole: 1000).to_f
  end

end
