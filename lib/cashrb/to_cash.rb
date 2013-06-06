require 'bigdecimal'

module ConvertsToCash
  def to_cash(opts={})
    Cash.new(self, opts)
  end
end

module ConvertsStringToCash
  def to_cash(opts={})
    Cash.new(cleaned_self, opts)
  end

  def cleaned_self
    self[/[\d\.\,]+/].gsub(',','')
  end
end

Fixnum.send(:include, ConvertsToCash)
Float.send(:include, ConvertsToCash)
BigDecimal.send(:include, ConvertsToCash)
String.send(:include, ConvertsStringToCash)