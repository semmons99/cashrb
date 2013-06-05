require 'bigdecimal'

module ConvertsToCash
  def to_cash
    Cash.new(self)
  end
end

module ConvertsStringToCash
  def to_cash
    Cash.new(cleaned_self)
  end

  def cleaned_self
    self[/[\d\.\,]+/].gsub(',','')
  end
end

Fixnum.send(:include, ConvertsToCash)
Float.send(:include, ConvertsToCash)
BigDecimal.send(:include, ConvertsToCash)
String.send(:include, ConvertsStringToCash)