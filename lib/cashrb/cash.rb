require 'bigdecimal'

##
# Provides methods for performing financial calculations without using floats.
class Cash
  include Comparable

  class IncompatibleCurrency < ArgumentError; end

  DEFAULT_CENTS_IN_WHOLE  = 100
  DEFAULT_ROUNDING_METHOD = BigDecimal::ROUND_HALF_UP
  DEFAULT_CURRENCY        = nil
  DEFAULT_FROM            = :cents

  VALID_FROMS             = [:cents, :decimal]

  CURRENCY_AWARE_METHODS  = [:+, :-, :/, :%, :divmod, :<=>]

  class << self
    def reset_defaults
      @default_cents_in_whole  = DEFAULT_CENTS_IN_WHOLE
      @default_rounding_method = DEFAULT_ROUNDING_METHOD
      @default_currency        = DEFAULT_CURRENCY
      @default_from            = DEFAULT_FROM
    end

    def valid_from?(from)
      VALID_FROMS.include? from
    end

    def bd(val)
      BigDecimal(val.to_s)
    end

    attr_accessor :default_cents_in_whole
    attr_accessor :default_rounding_method
    attr_accessor :default_currency
    attr_reader   :default_from

    def default_from=(from)
      unless valid_from? from
        raise ArgumentError, 
          "invalid ':from'. valid values are #{VALID_FROMS.join(",")}"
      end
      @default_from = from
    end
  end

  reset_defaults

  BD_ONE = bd(1)
  BD_TEN = bd(10)

  attr_reader :currency

  def initialize(amt = 0, options = {})
    opts = parse_initialize_options(options)
    @cents = bd(amt)

    if opts[:from] == :decimal
      dollars, cents = @cents.divmod(BD_ONE)
      @cents = (dollars * @cents_in_whole)
      @cents += (cents * (BD_TEN ** @decimal_places))
    end

    @cents = @cents.round(0, @rounding_method)
  end

  def cents
    @cents.to_i
  end

  def +(value)
    Cash.new(@cents + value.cents, new_options)
  end

  def -(value)
    Cash.new(@cents - value.cents, new_options)
  end

  def *(value)
    Cash.new(@cents * bd(value), new_options)
  end

  def /(value)
    @cents / value.cents
  rescue NoMethodError
    Cash.new(@cents / bd(value), new_options)
  end

  def %(value)
    Cash.new(@cents % value.cents, new_options)
  rescue NoMethodError
    Cash.new(@cents % bd(value), new_options)
  end

  def divmod(value)
    quotient, remainder = @cents.divmod value.cents
    [quotient, Cash.new(remainder, new_options)]
  rescue NoMethodError
    quotient, remainder = @cents.divmod bd(value)
    [Cash.new(quotient, new_options), Cash.new(remainder, new_options)]
  end

  def <=>(value)
    @cents <=> value.cents
  end

  def to_s
    return self.cents.to_s if @cents_in_whole == 1

    dollars, cents = dollars_and_cents
    "#{"-" if @cents < 0}#{dollars}.#{formatted_cents(cents)}"
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
    self.class.bd(val)
  end

  def dollars_and_cents
    @cents.abs.divmod(@cents_in_whole).map(&:to_i)
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
      :from            => self.class.default_from
    }.merge(options)

    @currency        = opts[:currency]
    @cents_in_whole  = if @currency.respond_to? :cents_in_whole
                         bd(@currency.cents_in_whole)
                       else
                         bd(opts[:cents_in_whole])
                       end
    @decimal_places  = decimal_places(@cents_in_whole)
    @rounding_method = opts[:rounding_method]

    unless self.class.valid_from? opts[:from]
      raise ArgumentError,
        "invalid ':from'. valid values are #{VALID_FROMS.join(",")}"
    end

    opts
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

  def new_options
    {
      :cents_in_whole  => @cents_in_whole,
      :rounding_method => @rounding_method,
      :currency        => @currency,
      :from            => :cents,
    }
  end

end
