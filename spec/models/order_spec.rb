# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Order do
  let(:structure)     { FactoryGirl.create(:structure) }

  describe '#next_order_id_for' do
    it 'increments order_id' do
      order_id = Order.next_order_id_for(structure)
      expect(order_id).to eq "FR#{Date.today.year}#{structure.id}#{structure.orders.count + 1}"
    end
  end

end
