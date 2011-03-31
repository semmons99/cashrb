require 'bigdecimal'

##
# Provides methods for performing financial calculations without using floats.
class Cash
  class IncompatibleCurrency < ArgumentError; end

  DEFAULT_CENTS_IN_WHOLE  = 100
  DEFAULT_ROUNDING_METHOD = BigDecimal::ROUND_HALF_UP
  DEFAULT_CURRENCY        = nil

  CURRENCY_AWARE_METHODS  = [
    :+, :-, :/, :%, :divmod, :==, :<=>, :>, :<, :>=, :<=
  ]

  class << self
    attr_accessor :default_cents_in_whole
    attr_accessor :default_rounding_method
    attr_accessor :default_currency

    def reset_defaults
      @default_cents_in_whole  = DEFAULT_CENTS_IN_WHOLE
      @default_rounding_method = DEFAULT_ROUNDING_METHOD
      @default_currency        = DEFAULT_CURRENCY
    end
  end

  reset_defaults

  attr_reader :currency

  def initialize(cents = 0, options = {})
    parse_initialize_options(options)
    @cents = bd(cents).round(0, @rounding_method)
  end

  def cents
    @cents.to_i
  end

  def +(value)
    Cash.new(@cents + value.cents)
  end

  def -(value)
    Cash.new(@cents - value.cents)
  end

  def *(value)
    Cash.new(@cents * bd(value))
  end

  def /(value)
    @cents / value.cents
  rescue NoMethodError
    Cash.new(@cents / bd(value))
  end

  def %(value)
    Cash.new(@cents % value.cents)
  rescue NoMethodError
    Cash.new(@cents % bd(value))
  end

  def divmod(value)
    quotient, remainder = @cents.divmod value.cents
    [quotient, Cash.new(remainder)]
  rescue NoMethodError
    quotient, remainder = @cents.divmod bd(value)
    [Cash.new(quotient), Cash.new(remainder)]
  end

  def ==(value)
    @cents == value.cents
  end

  def <=>(value)
    @cents <=> value.cents
  end

  def >(value)
    @cents > value.cents
  end

  def <(value)
    @cents < value.cents
  end

  def >=(value)
    @cents >= value.cents
  end

  def <=(value)
    @cents <= value.cents
  end

  def to_s
    return self.cents.to_s if @cents_in_whole == 1

    dollars, cents = dollars_and_cents
    "#{dollars}.#{formatted_cents(cents)}"
  end

  def to_f
    self.to_s.to_f
  end

  CURRENCY_AWARE_METHODS.each do |mth|
    old_mth = :"old_#{mth}"
    alias_method old_mth, mth
    private(old_mth)

    define_method(mth) do |value|
      reject_incompatible_currency(value)
      send(old_mth, value)
    end
  end

  private

  def bd(val)
    BigDecimal(val.to_s)
  end

  def dollars_and_cents
    @cents.divmod(@cents_in_whole).map(&:to_i)
  end

  def formatted_cents(cents)
    c = ("0" * @decimal_places) + cents.to_s
    c[(-1 * @decimal_places), @decimal_places]
  end

  def parse_initialize_options(options)
    opts = {
      :cents_in_whole  => self.class.default_cents_in_whole,
      :rounding_method => self.class.default_rounding_method,
      :currency        => self.class.default_currency,
    }.merge(options)

    @cents_in_whole  = opts[:cents_in_whole]
    @decimal_places  = decimal_places(@cents_in_whole)
    @rounding_method = opts[:rounding_method]
    @currency        = opts[:currency]
    nil
  end

  def decimal_places(cents_in_whole)
    bd(Math.log10(cents_in_whole)).round(0, BigDecimal::ROUND_UP).to_i
  end

  def reject_incompatible_currency(value)
    unless currency == value.currency
      raise IncompatibleCurrency, "#{value.currency} != #{currency}"
    end
  rescue NoMethodError
  end

end
