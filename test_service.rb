#!/usr/bin/env ruby

# Load Rails environment
require_relative 'config/environment'

puts "Testing TopSellingDaysService..."
puts "=" * 50

begin
  service = TopSellingDaysService.new
  result = service.call
  
  puts "✅ Service executed successfully!"
  puts "📧 Email should have been sent to edst83@gmail.com"
  puts "📊 Data returned: #{result.length} records"
  
  if result.any?
    puts "\n📈 Top 3 days:"
    result.first(3).each_with_index do |day, index|
      puts "  #{index + 1}. #{day['day']} - $#{day['total_amount']} (#{day['invoices_count']} invoices)"
    end
  end
  
rescue => e
  puts "❌ Error: #{e.message}"
  puts e.backtrace.first(5)
end

puts "\n" + "=" * 50
puts "Test completed!"
