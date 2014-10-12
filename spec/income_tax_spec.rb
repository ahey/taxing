require_relative 'spec_helper'

describe 'IncomeTaxCalculator' do
  let(:calculator) { ::Taxing::IncomeTaxCalculator.new(year) }

  describe '#new' do
    describe '2014 tax year' do
      let(:year) { 2014 }
      it 'is not supported' do
        expect { calculator }.to raise_error(ArgumentError)
      end
    end

    describe '2015 tax year' do
      let(:year) { 2015 }
      it 'is supported' do
        expect { calculator }.not_to raise_error
      end
    end
  end

  describe '#calculate' do
    let(:year) { 2015 }

    it 'does not allow the gross to be an int' do
      expect { calculator.calculate(85000) }.to raise_error(ArgumentError)
    end

    it 'does not allow the gross to be a float' do
      expect { calculator.calculate(85000.10) }.to raise_error(ArgumentError)
    end

    it 'allows the gross to be a BigDecimal' do
      expect do
       calculator.calculate(BigDecimal.new('85000.10'))
      end.not_to raise_error
    end

    it 'allows the gross to be a string' do
      expect { calculator.calculate('85000.10') }.not_to raise_error
    end

    test_data = {
      brackets: [
        { 
          name: '$0 - $18,200',
          test_data: [
            ['0.00', '0.00'],
            ['10000.00', '0.00'],
            ['18200.00', '0.00'],
            ['18200.99', '0.00'],
          ]
        }, {
          name: '$18,201 - $37,000',
          test_data: [
            ['18201.00', '0.19'],
            ['18202.00', '0.38'],
            ['30000.00', '2242.00'],
            ['30000.99', '2242.00'],
            ['37000.00', '3572.00'],
            ['37000.99', '3572.00'],
          ]
        }, {
          name: '$37,001 - $80,000',
          test_data: [
            ['37001.00', '3572.33'],
            ['37001.99', '3572.33'],
            ['37002.00', '3572.65'],
            ['60000.00', '11047.00'],
            ['80000.00', '17547.00'],
            ['80000.99', '17547.00'],
          ]
        }, {
          name: '$80,001 - $180,000',
          test_data: [
            ['80001.00', '17547.37'],
            ['80001.99', '17547.37'],
            ['120000.00', '32347.00'],
            ['180000.00', '54547'],
            ['180000.99', '54547'],
          ]
        }, {
          name: '$180,001 +',
          test_data: [
            ['180001.00', '54547.45'],
            ['180001.99', '54547.45'],
            ['200000', '63547'],
            ['2000000', '873547'],
          ]
        }
      ]
    }

    test_data[:brackets].each do |b|
      describe "#{b[:name]} bracket" do
        b[:test_data].each do |td|
          input = BigDecimal.new(td[0])
          expected = BigDecimal.new(td[1])

          describe "$#{'%0.2f' % input}" do
            it "returns $#{'%.2f' % expected}" do
              expect(calculator.calculate(input)).to eq(expected)
            end
          end  
        end
      end
    end

  end
end
