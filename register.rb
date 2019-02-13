#
# Register
#
# RUNNING
# > ruby register.rb <file>
#
# INPUT - a space delimited file with 1 item per line
# starting with the quantity, followed by a description
# and ending with the price:
#
# <integer> <description> at <decimal>
#
# Example
# =======
# 2 book at 12.49
# 1 music CD at 14.00
# 1 chocolate bar at 0.85
#
# Steps
# =====
# 1. Injest file on program startup
#    > ruby register.rb file.txt
# 2. Parse each line into quanity, description, price
# 3. Determine if line item is taxable 0.10
# 4. Determine if line item is imported 0.05
# 5. Calculate price for each line item based on quantity + taxes
# 6. Calculate taxes of all items
# 7. Calculate total price of all items
# 8. Output each line item total price
# 9. Output total sales tax
# 10. Output total price

class Basket

  attr_reader :file, :items

  def initialize file
    @file = file
    @items = []
    parse_items
  end

  def print_receipt
    print_items
    print_sales_tax
    print_total
  end

  def print_items
    items.each(&:print_receipt)
  end

  def total_tax
    items.sum { |i| i.total_tax * i.quantity }
  end

  def print_sales_tax
    tax = "%.2f" % total_tax
    puts "Sales Taxes: #{tax}"
  end

  def total_price
    items.sum(&:total_price)
  end

  def print_total
    total = "%.2f" % total_price
    puts "Total: #{total}"
  end

  private

  def parse_items
    File.open(@file).each_line do |line|
      data = line.match /(\d+) (.+) at (\d+\.\d+)/
      @items << Item.new(*data)
    end
  end

end

class Item
  SALES_TAX = 10
  IMPORT_TAX = 5
  attr_reader :quantity, :description, :price

  def initialize data, quantity, description, price
    @quantity = quantity.to_i
    @description = description.strip
    @price = price.to_f
  end

  def total_price
    (@quantity * (@price + total_tax)).round(2)
  end

  # add basic tax and import tax
  def total_tax
    basic_tax  = non_exempt? ? tax(SALES_TAX) : 0.0
    import_tax = imported? ? tax(IMPORT_TAX) : 0.0
    (basic_tax + import_tax).round(2)
  end

  # round up to nearest 0.05
  def tax rate
    n = ((rate * @price / 100.0) / 0.05).ceil
    (n * 0.05).round(2)
  end

  def exempt?
    /book|chocolate|pill/.match? @description
  end

  def non_exempt?
    !exempt?
  end

  def imported?
    /imported/.match? @description
  end

  def print_receipt
    tp = "%.2f" % total_price
    puts "#{@quantity} #{@description}: #{tp}"
  end
end

class TestEngine

  def run
    test_items_created
    test_item_total_price
    test_items_total_tax
    test_items_total_price
    puts
  end

  def test_items_created
    b = basket
    test b.items.size == 4
    test b.items.first.quantity == 1
    test b.items.first.description == 'imported bottle of perfume'
    test b.items.first.price == 27.99
  end

  def test_item_total_price
    b = basket
    test b.items[0].total_price == 32.19
    test b.items[1].total_price == 20.89
    test b.items[2].total_price == 9.75
    test b.items[3].total_price == 35.55 
  end

  def test_items_total_tax
    b = basket
    test b.total_tax == 7.90
  end

  def test_items_total_price
    b = basket
    test b.total_price == 98.38
  end

  private 

  def basket
    Basket.new('basket3.txt')
  end

  def test assertion
    print assertion ? '.' : 'F'
  end

end

arguments = ARGV
if arguments.size == 1
  case arguments.first
  when 'test'
    TestEngine.new.run()
  else
    basket = Basket.new(arguments.first)
    basket.print_receipt
  end
else
  puts "Please provide one input file or pass 'test' to run tests."
end