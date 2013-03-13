# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Price do
  it 'should return approximate price per course' do
    price = Price.new amount: 12412, nb_course: 124
    expect(price.per_course_amount).to eq(12412 / 124)
  end
end
