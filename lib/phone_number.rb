class PhoneNumber
  attr_accessor :number, :associated_words
  # Opens the dictionary file & stores it as a hash in a class variable 
  # The key is the length and the value is an array with words of specified length
  # This is done in order to ensure speed while iterating thru the dictionary
  @@dictionary = Proc.new{ File.open(File.join(File.expand_path(File.dirname(__FILE__)), '..', 'data', 'dictionary.txt'), 'r').readlines(chomp: true).group_by(&:length) }.call
  @@mapping = {
    '2' => [:A, :B, :C],
    '3' => [:D, :E, :F],
    '4' => [:G, :H, :I],
    '5' => [:J, :K, :L],
    '6' => [:M, :N, :O],
    '7' => [:P, :Q, :R, :S],
    '8' => [:T, :U, :V],
    '9' => [:W, :X, :Y, :Z]
  }

  def initialize(number='')
    # accepts number as attribute for new method
    self.number = number
    validate!
    self.to_words
  end

  def three_slice_processing
    mapped_digits = self.number.chars.map(&@@mapping.method(:[]))
    digit_count = mapped_digits.length
    converted_mapped_digits = (2..digit_count-2).each_with_object(Hash.new) do |idx, res_hash|
      slice1 = mapped_digits[0..idx]
      slice2 = mapped_digits[idx.next..idx.next+3] if !((digit_count - (idx.next+3)) < 3)
      slice3 = mapped_digits[slice2.nil? ? idx.next..digit_count : idx.next+3..digit_count]
      next if slice1.to_a.length < 3 || slice2.to_a.length < 3 || slice3.to_a.length < 3
      comb1 = slice1.shift.product(*slice1).map(&:join)
      comb2 = slice2.shift.product(*slice2).map(&:join)
      comb3 = slice3.shift.product(*slice3).map(&:join)
      next if [comb1, comb2, comb3].any?(&:nil?)
      res_hash[idx] = [(comb1.to_a & @@dictionary[comb1.to_a.sort_by(&:length).last.length]), 
                       (comb2.to_a & @@dictionary[comb2.to_a.sort_by(&:length).last.length]), 
                       (comb3.to_a & @@dictionary[comb2.to_a.sort_by(&:length).last.length])]
    end
    converted_mapped_digits.values.flatten(1).reject(&:empty?)
  end

  protected

  def validate!
    raise ArgumentError.new "Invalid Phone Number Entered" if self.number.length > 10 || self.number.match(/[0-1]/)
  end

  def to_words
    # replaces each digit with the mapping value from the @@mapping hash
    mapped_digits = self.number.chars.map(&@@mapping.method(:[]))
    digit_count = mapped_digits.length.pred
    processed_mapped_digits = (2..mapped_digits.length-3).each_with_object(Hash.new) do |idx, res_hash|
      # loops through the mapped_digits dividing the mapped_digits into two arrays of all length combinations 
      # where length of the mapped_digits is > 2
      conv_main_slice = mapped_digits[0..idx]
      conv_sub_slice = mapped_digits[idx.next..digit_count]
      next if conv_main_slice.length < 3 || conv_sub_slice.length < 3

      # Takes the first array element of the first slice of the mapped digits
      # creates an array of arrays which contain every possible combination of the first array element with the other array elements
      # Takes each array in the array of arrays and turns it into a string
      # same process is repeated for the second array as well
      main_slice_combs = conv_main_slice.shift.product(*conv_main_slice).map(&:join)
      sub_slice_combs = conv_sub_slice.shift.product(*conv_sub_slice).map(&:join)
      next if sub_slice_combs.nil? || main_slice_combs.nil?

      # using the array union operation, checks the dictionary for matching words with the same length for both divided arrays
      res_hash[idx] = [(main_slice_combs.to_a & @@dictionary[idx+1]), (sub_slice_combs.to_a & @@dictionary[digit_count-idx])]
    end
    word_combinations(processed_mapped_digits)
  end

  private

  def word_combinations(processed_combinations)
    # creates different combinations of elements of array passed into the method using the product function and removes any empty arrays 
    self.associated_words = processed_combinations.map{|strlen, comb| comb.first.product(comb.last)}.reject(&:empty?).flatten(1)
    
    # joins all combinations to check dictionary for words of greater length without splitting the original mapped digits into sub_arrays
    self.associated_words +=  self.associated_words.product(self.associated_words).map(&:flatten).map(&:uniq).map(&:join) & @@dictionary.values.flatten

    # element arrays which form larger words in dictionary when joined is removed from the original array
    self.associated_words = self.associated_words.reject{|word| word.is_a?(Array) && self.associated_words.include?(word.join())}
  end
end
