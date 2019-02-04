require_relative 'phone_number'
class Cli
  def initialize
    puts "Welcome to Phone Number Converter"; run
  end

  def run
    print "Enter a phone number: "
    number = gets.chomp.strip
    start_time = Time.now 
    phone = PhoneNumber.new(number)
    puts "Words the selected mobile are: "
    p phone.associated_words
    end_time = Time.now
    puts "Found #{phone.associated_words.length} words in #{end_time-start_time} seconds"
    algo2 = phone.three_slice_processing
    end_time2 = Time.now
    puts "\n"
    p algo2
    puts "Algorithm2 #{algo2.length} words in #{end_time2 - end_time} seconds"
  rescue ArgumentError => e
    puts "Entered Phone Number is Invalid: #{e}"
    retry
  end
end
