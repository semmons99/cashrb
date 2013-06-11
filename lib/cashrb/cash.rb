require 'bigdecimal'

##
# Provides methods for performing financial calculations without using floats.
class Cash
  include Comparable

  class IncompatibleCurrency < ArgumentError; end

  DEFAULT_CENTS_IN_WHOLE  = 100
  DEFAULT_ROUNDING_METHOD = BigDecimal::ROUND_HALF_UP
  DEFAULT_CURRENCY        = nil
  DEFAULT_VAT             = 20
  DEFAULT_VAT_INCLUDED    = :false
  DEFAULT_FROM            = :cents

  VALID_FROMS             = [:cents, :decimal]
  VALID_VAT_INCLUSION     = [:true, :false, :mixed]

  CURRENCY_AWARE_METHODS  = [:+, :-, :/, :%, :divmod, :<=>]

  class << self
    def reset_defaults
      @default_cents_in_whole  = DEFAULT_CENTS_IN_WHOLE
      @default_rounding_method = DEFAULT_ROUNDING_METHOD
      @default_currency        = DEFAULT_CURRENCY
      @default_vat             = DEFAULT_VAT
      @default_vat_included    = DEFAULT_VAT_INCLUDED
      @default_from            = DEFAULT_FROM
    end

    def valid_from?(from)
      VALID_FROMS.include? from
    end

    def valid_vat_inclusion?(inclusion)
      VALID_VAT_INCLUSION.include? inclusion
    end

    def bd(val)
      BigDecimal(val.to_s)
    end

    attr_accessor :default_cents_in_whole
    attr_accessor :default_rounding_method
    attr_accessor :default_currency
    attr_accessor :default_vat
    attr_reader   :default_vat_included
    attr_reader   :default_from

    def default_from=(from)
      unless valid_from? from
        raise ArgumentError, 
          "invalid ':from'. valid values are #{VALID_FROMS.join(",")}"
      end
      @default_from = from
    end

    def default_vat_included=(inclusion)
      unless valid_vat_inclusion? inclusion
        raise ArgumentError,
          "invalid ':vat_included'. valid values are #{VALID_VAT_INCLUSION.join(",")}"
      end
      @default_vat_included = inclusion
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

  alias_method :pence, :cents

  def cents_plus_vat
    if vat_included?
      cents
    else
      cents * (1 + (@vat/100))
    end
  end

  alias_method :pence_plus_vat, :cents_plus_vat

  def cents_less_vat
    if vat_included?
      cents / (1 + (@vat/100))
    else
      cents
    end
  end

  alias_method :pence_less_vat, :cents_less_vat

  def +(value)
    Cash.new(@cents + value.cents, new_options(value))
  end

  def -(value)
    Cash.new(@cents - value.cents, new_options(value))
  end

  def -@
    Cash.new(-@cents, new_options)
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

  def abs
    Cash.new(@cents.abs, new_options)
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

  def to_cash
    self
  end

  def vat_status
    @vat_included
  end

  def vat_included?
    vat_status == :true
  end

  def vat_mixed?
    vat_status == :mixed
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
      :vat             => self.class.default_vat,
      :vat_included    => self.class.default_vat_included,
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
    @vat             = bd(opts[:vat])
    @vat_included    = opts[:vat_included]

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

  def update_vat_status(new_vat_status)
    if @vat_included != new_vat_status
      @vat_included = :mixed
    end
  end

  def new_options(value=self)
    {
      :cents_in_whole  => @cents_in_whole,
      :rounding_method => @rounding_method,
      :currency        => @currency,
      :from            => :cents,
      :vat             => @vat,
      :vat_included    => update_vat_status(value.vat_status)
    }
  end

end
