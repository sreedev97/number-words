$:.unshift(File.join(File.expand_path(File.dirname(__FILE__)), '..', 'lib'))

require 'json'
require 'phone_number'

describe PhoneNumber do
  context "When passing in a valid 10 digit phone number" do
    spec_params = JSON.load(File.open("#{File.dirname(__FILE__)}/output.json", 'r'))
    spec_params.each do |spec| 
      it "should return all text combinations corresponding to #{spec['phone']}" do
        sample_valid_phone = PhoneNumber.new(spec['phone'])
        expect(sample_valid_phone.associated_words).to contain_exactly(*spec['expected_outcome'])
      end
    end
  end

  context "When passing an invalid phone number" do
    it "should raise an Argument Exception when numbers longer than 10 digits is passed" do
      expect { PhoneNumber.new("987678987678987") }.to raise_exception(ArgumentError)
    end

    it "should raise an exception when numbers with 0 or 1 is passed" do
      expect { PhoneNumber.new("1298390983") }.to raise_exception(ArgumentError)
    end
  end
end
