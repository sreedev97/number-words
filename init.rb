class NumberMapping
  attr_accessor :number, :associated_words
  @@dictionary = Proc.new{ File.open('./data/dictionary.txt', 'r').readlines(chomp: true).group_by(&:length) }.call
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
    self.number = number
  end

  def convert_to_words
    mapped_digits = self.number.chars.map(&@@mapping.method(:[]))
    digit_count = mapped_digits.length.pred
    processed_mapped_digits = (2..mapped_digits.length-3).each_with_object(Hash.new) do |idx, res_hash|
      conv_main_slice = mapped_digits[0..idx]
      conv_sub_slice = mapped_digits[idx.next..digit_count]
      next if conv_main_slice.length < 3 || conv_sub_slice.length < 3
      main_slice_combs = conv_main_slice.shift.product(*conv_main_slice).map(&:join)
      sub_slice_combs = conv_sub_slice.shift.product(*conv_sub_slice).map(&:join)
      next if sub_slice_combs.nil? || main_slice_combs.nil?
      res_hash[idx] = [(main_slice_combs.to_a & @@dictionary[idx+1]), (sub_slice_combs.to_a & @@dictionary[digit_count-idx])]
    end
    word_combinations(processed_mapped_digits)
  end

  def word_combinations(processed_combinations)
    self.associated_words = processed_combinations.map{|strlen, comb| comb.first.product(comb.last)}.reject(&:empty?).flatten(1)
    self.associated_words +=  self.associated_words.product(self.associated_words).map(&:flatten).map(&:uniq).map(&:join) & @@dictionary.values.flatten
  end
end

p NumberMapping.new("6686787825").convert_to_words
