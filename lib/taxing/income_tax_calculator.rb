require 'bigdecimal'

module Taxing

  # Calculate income tax on gross taxable income, without regard to tax offsets
  class IncomeTaxCalculator
    TAX_TABLES = [
      # See: https://www.ato.gov.au/individuals/income-and-deductions/how-much-income-tax-you-pay/individual-income-tax-rates/
      year: 2015,
      brackets: [
        { range: 0..18200, lump: 0, rate: 0 },
        { range: 18201..37000, lump: 0, rate: 0.19 },
        { range: 37001..80000, lump: 3572, rate: 0.325 },
        { range: 80001..180000, lump: 17547, rate: 0.37 },
        { above: 180001, lump: 54547, rate: 0.45 },
      ]
    ]
    
    attr_reader :year

    # Arguments: 
    #   year: (Integer) the year that the tax year ends in, e.g. 2015 is the 
    #                   2014-2015 tax year ending on 30th June 2015.
    def initialize(year)
      @year = year

      unless tax_table_for_year?(year)
        raise(ArgumentError, "The #{year} tax year is not supported")
      end
    end

    # Calculate income tax on gross taxable income
    def calculate(gross)
      gross = BigDecimal.new(gross) if gross.is_a?(String)

      unless gross.is_a?(BigDecimal)
        raise(ArgumentError, 'Gross income must be a BigDecimal')
      end

      tax_brackets_for_year(@year).each do |bracket|
        if falls_in_bracket(bracket, gross)
          lump = BigDecimal.new(bracket[:lump].to_s)
          taxable = whole_dollars_in_bracket(bracket, gross)
          tax = taxable * BigDecimal.new(bracket[:rate].to_s)
          return (lump + tax).round(2)
        end
      end
    end

    private

    def tax_brackets_for_year(year)
      TAX_TABLES.detect{|table| table[:year] == year}[:brackets]
    end

    def tax_table_for_year?(year)
      TAX_TABLES.any?{|table| table[:year] == year}
    end

    def whole_dollars_in_bracket(bracket, gross)
      range_start = bracket[:above] || bracket[:range].begin
      taxable = gross - BigDecimal.new((range_start - 1).to_s)
      return taxable.round(0, BigDecimal::ROUND_DOWN)
    end

    def falls_in_bracket(bracket, gross)
      if bracket[:range]
        return gross < (BigDecimal.new(bracket[:range].end.to_s) + 1)
      else
        return gross >= BigDecimal.new(bracket[:above].to_s)
      end
    end
  end

end