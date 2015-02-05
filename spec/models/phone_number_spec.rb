# -*- encoding : utf-8 -*-
require 'rails_helper'

describe PhoneNumber do
  describe '#is_mobile?' do

    it 'is a mobile phone number' do
      mobile_phone_numbers = ['+33(0)6 49 49 62 56', '06 49 49 62 56', '+336 49 49 62 56',
                              '+337 49 49 62 56', '+33(0)6 49 49 62 56', '00336 49 49 62 56',
                              '07 49 49 62 56']
      mobile_phone_numbers.each do |number|
        phone_number = PhoneNumber.new number: number
        expect(phone_number.mobile?).to be_truthy
      end
    end

    it 'is not a mobile phone number' do
      mobile_phone_numbers = ['+33(0)1 49 49 62 56', '01 49 49 62 56', '+331 49 49 62 56',
                              '+331 49 49 62 56', '+33(0)1 49 49 62 56', '00331 49 49 62 56',
                              '01 49 49 62 56']
      mobile_phone_numbers.each do |number|
        phone_number = PhoneNumber.new number: number
        expect(phone_number.mobile?).to be_falsy
      end
    end
  end
end
