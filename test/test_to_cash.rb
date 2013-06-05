# encoding: utf-8

require 'minitest/autorun'
require 'bigdecimal'
require 'cashrb/cash'
require 'cashrb/to_cash'

class TestToCash < MiniTest::Unit::TestCase
  def test_fixnums_convert_to_cash_objects
    assert_equal 12345.to_cash, Cash.new(12345)
  end
  def test_floats_convert_to_cash_objects
    assert_equal 123.45.to_cash, Cash.new(123.45)
  end
  def test_big_decimal_convert_to_cash_objects
    assert_equal BigDecimal.new(12345).to_cash, Cash.new(BigDecimal.new(12345))
  end
  def test_string_convert_to_cash_objects
    assert_equal '12345'.to_cash, Cash.new(12345)
  end
  def test_decimal_string_convert_to_cash_objects
    assert_equal '123.45'.to_cash, Cash.new(123.45)
  end
  def test_formatted_string_convert_to_cash_objects
    assert_equal '£123.45'.to_cash, Cash.new(123.45)
    assert_equal '£12,345.67'.to_cash, Cash.new(12345.67)
  end
  def test_cash_objects_convert_to_cash_objects
    assert_equal Cash.new(123.45).to_cash, Cash.new(123.45)
  end
  def test_passes_options_through_on_numerics
    assert_equal 123.45.to_cash(decimal: true), Cash.new(123.45, decimal: true)
  end
  def test_passes_options_through_on_strings
    assert_equal '£123.45'.to_cash(decimal: true), Cash.new(123.45, decimal: true)
  end
end