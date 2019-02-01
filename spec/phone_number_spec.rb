$:.unshift(File.join(File.expand_path(File.dirname(__FILE__)), '..', 'lib'))

require 'json'
require 'phone_number'

describe PhoneNumber do
  context "When passing in a valid 10 digit phone number" do
    spec_params = JSON.load(File.open("#{File.dirname(__FILE__)}/output.json", 'r'))
    spec_params.each do |spec| 
      it "should return all text combinations corresponding to #{spec['phone']}" do
        sample_phone = PhoneNumber.new(spec['phone'])
        expect(sample_phone.to_words).to contain_exactly(*spec['expected_outcome'])
      end
    end
  end
end
