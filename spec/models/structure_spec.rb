# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Strcuture do
  describe :factories do
    subject {structure}
    context :structure do
      let(:structure) {FactoryGirl.build(:structure)}

      it {should be_valid}
      # it {should have(1).teacher}
    end
  end
end

